
include irvine32.inc

; Write a procedure named Str_find that searches for the first matching occurrence of a source string 
; inside a target string and returns the matching position. 
; The input prameters should be a pointer to the source string and a point to the target string. 
; If a match is found, the procedure sets the Zero flag and EAX points to the matching position in the target string. 
; Otherwise, the Zero flag is clear and EAX is undefined. 


.data
    sourcePrompt byte "Enter the source string (the string to search for): ", 0
    targetPrompt byte "Enter the target string (the string to search from): ", 0
    foundOutput1 byte "Source string found at position ", 0
    foundOutput2 byte " in target string. (Counting from zero)", 0
    debugOutput byte "eax value is: ", 0
    debugOutput1 byte "value of offset target is: ", 0
    notFoundOutput byte "String not found.", 0
    againPrompt byte "Do you want to do another search? Press 'y' if yes: ", 0
    source byte 80 DUP("#"), 0
    target byte SIZEOF source DUP('#')

.code
Str_find proc
; Takes pointers to two strings. Looks for the target string within the source string.
; Recieves: EAX pointer to source string, EBX pointer to target string
; Returns: If found, EAX pointer to the target string position, zero flag set.

    mov esi, eax
    mov edi, ebx

    ; Find a first character match. Then run a full test.
    ; Loop through the target string trying to find a match with first char of source.
    ; If found, FoundFirst.  Otherwise NoMatch if nullchar of target is found.
    ; (1) check if target is null. NoMatch if null.
    ; (2) compare current target char with first source char. FoundFirst if equal. Increment edi and try again if not.

    L1:
    mov cl, [esi]
    mov ch, [edi]
    cmp ch, 0
    je NoMatch      ; checking if at end of target string
    cmp cl, ch
    je FoundFirst
    inc edi
    jmp L1



    FoundFirst:
    mov edx, edi        ; store first char target location
    ; Try to loop through source string. Go back to L1 if there is a mismatch.
    ; If reaching the end of source, FoundMatch. If reaching end of target, NoMatch.
    ; (1) Increment both esi and edi. if esi=0, FoundMatch. if edi=0, NoMatch.
    ; (2) Compare esi edi. If equal, repeat (1). 
    ; (3) Otherwise mov esi, eax to reset source pointer to start. Reset target pointer to the char after ecx and goto L1.
    ;
    L2:
    inc esi
    mov cl, [esi]
    cmp cl, 0
    je FoundMatch
    inc edi
    mov ch, [edi]
    cmp ch, 0
    je NoMatch
    cmp ch, cl
    je L2
    mov esi, eax
    mov edi, edx
    inc edi
    jmp L1

    NoMatch:    ; zf=0 and return
    or al, 1        ; clears zf
    ret

    FoundMatch:    ; zf=1 and eax points to first char match
    mov eax, edx        ; first char location
    and cl, 0       ; set zero flag
    ret
Str_find endp

main PROC
    ProgramStart:
    ; Ask for source string and record it into source
    mov edx, offset sourcePrompt
    call WriteString
    mov edx, offset source
    mov ecx, sizeof source
    call ReadString

    ; Ask for target string and record it into target
    mov edx, offset targetPrompt
    call WriteString
    mov edx, offset target
    mov ecx, sizeof target
    call ReadString

    ; call string comparison procedure
    mov eax, offset source
    mov ebx, offset target
    call Str_find

    ; if found:
    jnz NotFound                    ; if zero flag is not set, jump to NotFound label
    mov edx, offset foundOutput1
    call WriteString

    ; display position
    ; eax is pointer to target string match position.
    ; subtract the start of target string location from the match position to get the position in the string.
    ; WriteDec displays eax int value
    sub eax, offset target
    call WriteDec             
    mov edx, offset foundOutput2
    call WriteString
    jmp EndOutputIf

    NotFound:
    mov edx, offset notFoundOutput
    call WriteString
    ; end if
    EndOutputIf:
    
    call crlf    
    call crlf

    mov edx, offset againPrompt
    call WriteString
    call ReadChar               ; Get menu selection into al as char
    call WriteChar              ; Display menu selection
    call crlf
    cmp al, 'y'
    je ProgramStart

    exit
main ENDP
end main
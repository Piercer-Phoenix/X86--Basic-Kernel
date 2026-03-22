#include "vga.h"
#include "io.h"

static int x = 0;
static int y = 0;

void clear(void){
    char* vga = (char*) 0xB8000;
    for(int i = 0; i < 80*25*2; i += 2) {
        vga[i] = ' ';
        vga[i+1] = 0x07;
    }
}

void putchar(char c){
    if (c == '\n'){
        x=0;
        y++;
    }
    else{
        char* vga = (char*) 0xB8000;
        int offset =((y*80) + x) * 2;
        
        vga[offset] = c;
        vga[offset + 1] = 0x0f;
        x++;
        if (x>=80){
            y++;
            x=0;
        }
}
}

void print(char * str){
    int i = 0;
    while(str[i] != '\0'){
        putchar(str[i]);
        i++;
    }

}

void move_cursor(){

}
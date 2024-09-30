;; Video memory @ 0xa0000
[extern write_line]
[extern print_hex]
[extern put_char]
[extern clear_screen]
[extern currx]
[extern curry]
[extern disable_cursor]

%define BLACK_BACKGROUND	0x00
%define BLUE_BACKGROUND		0x10
%define GREEN_BACKGROUND	0x20
%define CYAN_BACKGROUND		0x30
%define RED_BACKGROUND		0x40
%define PURPLE_BACKGROUND	0x50
%define BROWN_BACKGROUND	0x60
%define GREY_BACKGROUND		0x70
%define DARK_GREY_BACKGROUND	0x80
%define LIGHT_BLUE_BACKGROUND	0x90
%define LIGHT_GREEN_BACKGROUND	0xa0
%define LIGHT_CYAN_BACKGROUND	0xb0
%define LIGHT_RED_BACKGROUND	0xc0
%define LIGHT_PURPLE_BACKGROUND	0xd0
%define YELLOW_BACKGROUND	0xe0
%define WHITE_BACKGROUND	0xf0

%define SCREEN_WIDTH		0x50
%define SCREEN_HEIGHT		0x19

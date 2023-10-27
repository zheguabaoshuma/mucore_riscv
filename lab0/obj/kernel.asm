
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080100000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80100000:	00003117          	auipc	sp,0x3
    80100004:	00010113          	mv	sp,sp

    tail kern_init
    80100008:	a009                	j	8010000a <kern_init>

000000008010000a <kern_init>:
#include <sbi.h>
int kern_init(void) __attribute__((noreturn));

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8010000a:	00003517          	auipc	a0,0x3
    8010000e:	ffe50513          	addi	a0,a0,-2 # 80103008 <edata>
    80100012:	00003617          	auipc	a2,0x3
    80100016:	ff660613          	addi	a2,a2,-10 # 80103008 <edata>
int kern_init(void) {
    8010001a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8010001c:	4581                	li	a1,0
    8010001e:	8e09                	sub	a2,a2,a0
int kern_init(void) {
    80100020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80100022:	494000ef          	jal	ra,801004b6 <memset>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    80100026:	00000597          	auipc	a1,0x0
    8010002a:	4a258593          	addi	a1,a1,1186 # 801004c8 <memset+0x12>
    8010002e:	00000517          	auipc	a0,0x0
    80100032:	4ba50513          	addi	a0,a0,1210 # 801004e8 <memset+0x32>
    80100036:	020000ef          	jal	ra,80100056 <cprintf>
   while (1)
    8010003a:	a001                	j	8010003a <kern_init+0x30>

000000008010003c <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    8010003c:	1141                	addi	sp,sp,-16
    8010003e:	e022                	sd	s0,0(sp)
    80100040:	e406                	sd	ra,8(sp)
    80100042:	842e                	mv	s0,a1
    cons_putc(c);
    80100044:	048000ef          	jal	ra,8010008c <cons_putc>
    (*cnt)++;
    80100048:	401c                	lw	a5,0(s0)
}
    8010004a:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    8010004c:	2785                	addiw	a5,a5,1
    8010004e:	c01c                	sw	a5,0(s0)
}
    80100050:	6402                	ld	s0,0(sp)
    80100052:	0141                	addi	sp,sp,16
    80100054:	8082                	ret

0000000080100056 <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    80100056:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    80100058:	02810313          	addi	t1,sp,40 # 80103028 <edata+0x20>
int cprintf(const char *fmt, ...) {
    8010005c:	8e2a                	mv	t3,a0
    8010005e:	f42e                	sd	a1,40(sp)
    80100060:	f832                	sd	a2,48(sp)
    80100062:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80100064:	00000517          	auipc	a0,0x0
    80100068:	fd850513          	addi	a0,a0,-40 # 8010003c <cputch>
    8010006c:	004c                	addi	a1,sp,4
    8010006e:	869a                	mv	a3,t1
    80100070:	8672                	mv	a2,t3
int cprintf(const char *fmt, ...) {
    80100072:	ec06                	sd	ra,24(sp)
    80100074:	e0ba                	sd	a4,64(sp)
    80100076:	e4be                	sd	a5,72(sp)
    80100078:	e8c2                	sd	a6,80(sp)
    8010007a:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    8010007c:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    8010007e:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80100080:	07e000ef          	jal	ra,801000fe <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80100084:	60e2                	ld	ra,24(sp)
    80100086:	4512                	lw	a0,4(sp)
    80100088:	6125                	addi	sp,sp,96
    8010008a:	8082                	ret

000000008010008c <cons_putc>:

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    8010008c:	0ff57513          	andi	a0,a0,255
    80100090:	aec5                	j	80100480 <sbi_console_putchar>

0000000080100092 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    80100092:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80100096:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    80100098:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    8010009c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    8010009e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    801000a2:	f022                	sd	s0,32(sp)
    801000a4:	ec26                	sd	s1,24(sp)
    801000a6:	e84a                	sd	s2,16(sp)
    801000a8:	f406                	sd	ra,40(sp)
    801000aa:	e44e                	sd	s3,8(sp)
    801000ac:	84aa                	mv	s1,a0
    801000ae:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    801000b0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    801000b4:	2a01                	sext.w	s4,s4
    if (num >= base) {
    801000b6:	03067e63          	bgeu	a2,a6,801000f2 <printnum+0x60>
    801000ba:	89be                	mv	s3,a5
        while (-- width > 0)
    801000bc:	00805763          	blez	s0,801000ca <printnum+0x38>
    801000c0:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    801000c2:	85ca                	mv	a1,s2
    801000c4:	854e                	mv	a0,s3
    801000c6:	9482                	jalr	s1
        while (-- width > 0)
    801000c8:	fc65                	bnez	s0,801000c0 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    801000ca:	1a02                	slli	s4,s4,0x20
    801000cc:	00000797          	auipc	a5,0x0
    801000d0:	42478793          	addi	a5,a5,1060 # 801004f0 <memset+0x3a>
    801000d4:	020a5a13          	srli	s4,s4,0x20
    801000d8:	9a3e                	add	s4,s4,a5
}
    801000da:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    801000dc:	000a4503          	lbu	a0,0(s4)
}
    801000e0:	70a2                	ld	ra,40(sp)
    801000e2:	69a2                	ld	s3,8(sp)
    801000e4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    801000e6:	85ca                	mv	a1,s2
    801000e8:	87a6                	mv	a5,s1
}
    801000ea:	6942                	ld	s2,16(sp)
    801000ec:	64e2                	ld	s1,24(sp)
    801000ee:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    801000f0:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    801000f2:	03065633          	divu	a2,a2,a6
    801000f6:	8722                	mv	a4,s0
    801000f8:	f9bff0ef          	jal	ra,80100092 <printnum>
    801000fc:	b7f9                	j	801000ca <printnum+0x38>

00000000801000fe <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    801000fe:	7119                	addi	sp,sp,-128
    80100100:	f4a6                	sd	s1,104(sp)
    80100102:	f0ca                	sd	s2,96(sp)
    80100104:	ecce                	sd	s3,88(sp)
    80100106:	e8d2                	sd	s4,80(sp)
    80100108:	e4d6                	sd	s5,72(sp)
    8010010a:	e0da                	sd	s6,64(sp)
    8010010c:	fc5e                	sd	s7,56(sp)
    8010010e:	f06a                	sd	s10,32(sp)
    80100110:	fc86                	sd	ra,120(sp)
    80100112:	f8a2                	sd	s0,112(sp)
    80100114:	f862                	sd	s8,48(sp)
    80100116:	f466                	sd	s9,40(sp)
    80100118:	ec6e                	sd	s11,24(sp)
    8010011a:	892a                	mv	s2,a0
    8010011c:	84ae                	mv	s1,a1
    8010011e:	8d32                	mv	s10,a2
    80100120:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80100122:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    80100126:	5b7d                	li	s6,-1
    80100128:	00000a97          	auipc	s5,0x0
    8010012c:	3fca8a93          	addi	s5,s5,1020 # 80100524 <memset+0x6e>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80100130:	00000b97          	auipc	s7,0x0
    80100134:	5d0b8b93          	addi	s7,s7,1488 # 80100700 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80100138:	000d4503          	lbu	a0,0(s10)
    8010013c:	001d0413          	addi	s0,s10,1
    80100140:	01350a63          	beq	a0,s3,80100154 <vprintfmt+0x56>
            if (ch == '\0') {
    80100144:	c121                	beqz	a0,80100184 <vprintfmt+0x86>
            putch(ch, putdat);
    80100146:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80100148:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    8010014a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8010014c:	fff44503          	lbu	a0,-1(s0)
    80100150:	ff351ae3          	bne	a0,s3,80100144 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
    80100154:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    80100158:	02000793          	li	a5,32
        lflag = altflag = 0;
    8010015c:	4c81                	li	s9,0
    8010015e:	4881                	li	a7,0
        width = precision = -1;
    80100160:	5c7d                	li	s8,-1
    80100162:	5dfd                	li	s11,-1
    80100164:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
    80100168:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
    8010016a:	fdd6059b          	addiw	a1,a2,-35
    8010016e:	0ff5f593          	andi	a1,a1,255
    80100172:	00140d13          	addi	s10,s0,1
    80100176:	04b56263          	bltu	a0,a1,801001ba <vprintfmt+0xbc>
    8010017a:	058a                	slli	a1,a1,0x2
    8010017c:	95d6                	add	a1,a1,s5
    8010017e:	4194                	lw	a3,0(a1)
    80100180:	96d6                	add	a3,a3,s5
    80100182:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80100184:	70e6                	ld	ra,120(sp)
    80100186:	7446                	ld	s0,112(sp)
    80100188:	74a6                	ld	s1,104(sp)
    8010018a:	7906                	ld	s2,96(sp)
    8010018c:	69e6                	ld	s3,88(sp)
    8010018e:	6a46                	ld	s4,80(sp)
    80100190:	6aa6                	ld	s5,72(sp)
    80100192:	6b06                	ld	s6,64(sp)
    80100194:	7be2                	ld	s7,56(sp)
    80100196:	7c42                	ld	s8,48(sp)
    80100198:	7ca2                	ld	s9,40(sp)
    8010019a:	7d02                	ld	s10,32(sp)
    8010019c:	6de2                	ld	s11,24(sp)
    8010019e:	6109                	addi	sp,sp,128
    801001a0:	8082                	ret
            padc = '0';
    801001a2:	87b2                	mv	a5,a2
            goto reswitch;
    801001a4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    801001a8:	846a                	mv	s0,s10
    801001aa:	00140d13          	addi	s10,s0,1
    801001ae:	fdd6059b          	addiw	a1,a2,-35
    801001b2:	0ff5f593          	andi	a1,a1,255
    801001b6:	fcb572e3          	bgeu	a0,a1,8010017a <vprintfmt+0x7c>
            putch('%', putdat);
    801001ba:	85a6                	mv	a1,s1
    801001bc:	02500513          	li	a0,37
    801001c0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    801001c2:	fff44783          	lbu	a5,-1(s0)
    801001c6:	8d22                	mv	s10,s0
    801001c8:	f73788e3          	beq	a5,s3,80100138 <vprintfmt+0x3a>
    801001cc:	ffed4783          	lbu	a5,-2(s10)
    801001d0:	1d7d                	addi	s10,s10,-1
    801001d2:	ff379de3          	bne	a5,s3,801001cc <vprintfmt+0xce>
    801001d6:	b78d                	j	80100138 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
    801001d8:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
    801001dc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    801001e0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    801001e2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    801001e6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    801001ea:	02d86463          	bltu	a6,a3,80100212 <vprintfmt+0x114>
                ch = *fmt;
    801001ee:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
    801001f2:	002c169b          	slliw	a3,s8,0x2
    801001f6:	0186873b          	addw	a4,a3,s8
    801001fa:	0017171b          	slliw	a4,a4,0x1
    801001fe:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
    80100200:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
    80100204:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    80100206:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
    8010020a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    8010020e:	fed870e3          	bgeu	a6,a3,801001ee <vprintfmt+0xf0>
            if (width < 0)
    80100212:	f40ddce3          	bgez	s11,8010016a <vprintfmt+0x6c>
                width = precision, precision = -1;
    80100216:	8de2                	mv	s11,s8
    80100218:	5c7d                	li	s8,-1
    8010021a:	bf81                	j	8010016a <vprintfmt+0x6c>
            if (width < 0)
    8010021c:	fffdc693          	not	a3,s11
    80100220:	96fd                	srai	a3,a3,0x3f
    80100222:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
    80100226:	00144603          	lbu	a2,1(s0)
    8010022a:	2d81                	sext.w	s11,s11
    8010022c:	846a                	mv	s0,s10
            goto reswitch;
    8010022e:	bf35                	j	8010016a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
    80100230:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    80100234:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80100238:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
    8010023a:	846a                	mv	s0,s10
            goto process_precision;
    8010023c:	bfd9                	j	80100212 <vprintfmt+0x114>
    if (lflag >= 2) {
    8010023e:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80100240:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80100244:	01174463          	blt	a4,a7,8010024c <vprintfmt+0x14e>
    else if (lflag) {
    80100248:	1a088e63          	beqz	a7,80100404 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
    8010024c:	000a3603          	ld	a2,0(s4)
    80100250:	46c1                	li	a3,16
    80100252:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
    80100254:	2781                	sext.w	a5,a5
    80100256:	876e                	mv	a4,s11
    80100258:	85a6                	mv	a1,s1
    8010025a:	854a                	mv	a0,s2
    8010025c:	e37ff0ef          	jal	ra,80100092 <printnum>
            break;
    80100260:	bde1                	j	80100138 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
    80100262:	000a2503          	lw	a0,0(s4)
    80100266:	85a6                	mv	a1,s1
    80100268:	0a21                	addi	s4,s4,8
    8010026a:	9902                	jalr	s2
            break;
    8010026c:	b5f1                	j	80100138 <vprintfmt+0x3a>
    if (lflag >= 2) {
    8010026e:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80100270:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80100274:	01174463          	blt	a4,a7,8010027c <vprintfmt+0x17e>
    else if (lflag) {
    80100278:	18088163          	beqz	a7,801003fa <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
    8010027c:	000a3603          	ld	a2,0(s4)
    80100280:	46a9                	li	a3,10
    80100282:	8a2e                	mv	s4,a1
    80100284:	bfc1                	j	80100254 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
    80100286:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    8010028a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
    8010028c:	846a                	mv	s0,s10
            goto reswitch;
    8010028e:	bdf1                	j	8010016a <vprintfmt+0x6c>
            putch(ch, putdat);
    80100290:	85a6                	mv	a1,s1
    80100292:	02500513          	li	a0,37
    80100296:	9902                	jalr	s2
            break;
    80100298:	b545                	j	80100138 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
    8010029a:	00144603          	lbu	a2,1(s0)
            lflag ++;
    8010029e:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
    801002a0:	846a                	mv	s0,s10
            goto reswitch;
    801002a2:	b5e1                	j	8010016a <vprintfmt+0x6c>
    if (lflag >= 2) {
    801002a4:	4705                	li	a4,1
            precision = va_arg(ap, int);
    801002a6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    801002aa:	01174463          	blt	a4,a7,801002b2 <vprintfmt+0x1b4>
    else if (lflag) {
    801002ae:	14088163          	beqz	a7,801003f0 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
    801002b2:	000a3603          	ld	a2,0(s4)
    801002b6:	46a1                	li	a3,8
    801002b8:	8a2e                	mv	s4,a1
    801002ba:	bf69                	j	80100254 <vprintfmt+0x156>
            putch('0', putdat);
    801002bc:	03000513          	li	a0,48
    801002c0:	85a6                	mv	a1,s1
    801002c2:	e03e                	sd	a5,0(sp)
    801002c4:	9902                	jalr	s2
            putch('x', putdat);
    801002c6:	85a6                	mv	a1,s1
    801002c8:	07800513          	li	a0,120
    801002cc:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    801002ce:	0a21                	addi	s4,s4,8
            goto number;
    801002d0:	6782                	ld	a5,0(sp)
    801002d2:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    801002d4:	ff8a3603          	ld	a2,-8(s4)
            goto number;
    801002d8:	bfb5                	j	80100254 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
    801002da:	000a3403          	ld	s0,0(s4)
    801002de:	008a0713          	addi	a4,s4,8
    801002e2:	e03a                	sd	a4,0(sp)
    801002e4:	14040263          	beqz	s0,80100428 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
    801002e8:	0fb05763          	blez	s11,801003d6 <vprintfmt+0x2d8>
    801002ec:	02d00693          	li	a3,45
    801002f0:	0cd79163          	bne	a5,a3,801003b2 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    801002f4:	00044783          	lbu	a5,0(s0)
    801002f8:	0007851b          	sext.w	a0,a5
    801002fc:	cf85                	beqz	a5,80100334 <vprintfmt+0x236>
    801002fe:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
    80100302:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80100306:	000c4563          	bltz	s8,80100310 <vprintfmt+0x212>
    8010030a:	3c7d                	addiw	s8,s8,-1
    8010030c:	036c0263          	beq	s8,s6,80100330 <vprintfmt+0x232>
                    putch('?', putdat);
    80100310:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80100312:	0e0c8e63          	beqz	s9,8010040e <vprintfmt+0x310>
    80100316:	3781                	addiw	a5,a5,-32
    80100318:	0ef47b63          	bgeu	s0,a5,8010040e <vprintfmt+0x310>
                    putch('?', putdat);
    8010031c:	03f00513          	li	a0,63
    80100320:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80100322:	000a4783          	lbu	a5,0(s4)
    80100326:	3dfd                	addiw	s11,s11,-1
    80100328:	0a05                	addi	s4,s4,1
    8010032a:	0007851b          	sext.w	a0,a5
    8010032e:	ffe1                	bnez	a5,80100306 <vprintfmt+0x208>
            for (; width > 0; width --) {
    80100330:	01b05963          	blez	s11,80100342 <vprintfmt+0x244>
    80100334:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80100336:	85a6                	mv	a1,s1
    80100338:	02000513          	li	a0,32
    8010033c:	9902                	jalr	s2
            for (; width > 0; width --) {
    8010033e:	fe0d9be3          	bnez	s11,80100334 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
    80100342:	6a02                	ld	s4,0(sp)
    80100344:	bbd5                	j	80100138 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80100346:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80100348:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
    8010034c:	01174463          	blt	a4,a7,80100354 <vprintfmt+0x256>
    else if (lflag) {
    80100350:	08088d63          	beqz	a7,801003ea <vprintfmt+0x2ec>
        return va_arg(*ap, long);
    80100354:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    80100358:	0a044d63          	bltz	s0,80100412 <vprintfmt+0x314>
            num = getint(&ap, lflag);
    8010035c:	8622                	mv	a2,s0
    8010035e:	8a66                	mv	s4,s9
    80100360:	46a9                	li	a3,10
    80100362:	bdcd                	j	80100254 <vprintfmt+0x156>
            err = va_arg(ap, int);
    80100364:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80100368:	4719                	li	a4,6
            err = va_arg(ap, int);
    8010036a:	0a21                	addi	s4,s4,8
            if (err < 0) {
    8010036c:	41f7d69b          	sraiw	a3,a5,0x1f
    80100370:	8fb5                	xor	a5,a5,a3
    80100372:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80100376:	02d74163          	blt	a4,a3,80100398 <vprintfmt+0x29a>
    8010037a:	00369793          	slli	a5,a3,0x3
    8010037e:	97de                	add	a5,a5,s7
    80100380:	639c                	ld	a5,0(a5)
    80100382:	cb99                	beqz	a5,80100398 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
    80100384:	86be                	mv	a3,a5
    80100386:	00000617          	auipc	a2,0x0
    8010038a:	19a60613          	addi	a2,a2,410 # 80100520 <memset+0x6a>
    8010038e:	85a6                	mv	a1,s1
    80100390:	854a                	mv	a0,s2
    80100392:	0ce000ef          	jal	ra,80100460 <printfmt>
    80100396:	b34d                	j	80100138 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    80100398:	00000617          	auipc	a2,0x0
    8010039c:	17860613          	addi	a2,a2,376 # 80100510 <memset+0x5a>
    801003a0:	85a6                	mv	a1,s1
    801003a2:	854a                	mv	a0,s2
    801003a4:	0bc000ef          	jal	ra,80100460 <printfmt>
    801003a8:	bb41                	j	80100138 <vprintfmt+0x3a>
                p = "(null)";
    801003aa:	00000417          	auipc	s0,0x0
    801003ae:	15e40413          	addi	s0,s0,350 # 80100508 <memset+0x52>
                for (width -= strnlen(p, precision); width > 0; width --) {
    801003b2:	85e2                	mv	a1,s8
    801003b4:	8522                	mv	a0,s0
    801003b6:	e43e                	sd	a5,8(sp)
    801003b8:	0e2000ef          	jal	ra,8010049a <strnlen>
    801003bc:	40ad8dbb          	subw	s11,s11,a0
    801003c0:	01b05b63          	blez	s11,801003d6 <vprintfmt+0x2d8>
                    putch(padc, putdat);
    801003c4:	67a2                	ld	a5,8(sp)
    801003c6:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
    801003ca:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    801003cc:	85a6                	mv	a1,s1
    801003ce:	8552                	mv	a0,s4
    801003d0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    801003d2:	fe0d9ce3          	bnez	s11,801003ca <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    801003d6:	00044783          	lbu	a5,0(s0)
    801003da:	00140a13          	addi	s4,s0,1
    801003de:	0007851b          	sext.w	a0,a5
    801003e2:	d3a5                	beqz	a5,80100342 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
    801003e4:	05e00413          	li	s0,94
    801003e8:	bf39                	j	80100306 <vprintfmt+0x208>
        return va_arg(*ap, int);
    801003ea:	000a2403          	lw	s0,0(s4)
    801003ee:	b7ad                	j	80100358 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
    801003f0:	000a6603          	lwu	a2,0(s4)
    801003f4:	46a1                	li	a3,8
    801003f6:	8a2e                	mv	s4,a1
    801003f8:	bdb1                	j	80100254 <vprintfmt+0x156>
    801003fa:	000a6603          	lwu	a2,0(s4)
    801003fe:	46a9                	li	a3,10
    80100400:	8a2e                	mv	s4,a1
    80100402:	bd89                	j	80100254 <vprintfmt+0x156>
    80100404:	000a6603          	lwu	a2,0(s4)
    80100408:	46c1                	li	a3,16
    8010040a:	8a2e                	mv	s4,a1
    8010040c:	b5a1                	j	80100254 <vprintfmt+0x156>
                    putch(ch, putdat);
    8010040e:	9902                	jalr	s2
    80100410:	bf09                	j	80100322 <vprintfmt+0x224>
                putch('-', putdat);
    80100412:	85a6                	mv	a1,s1
    80100414:	02d00513          	li	a0,45
    80100418:	e03e                	sd	a5,0(sp)
    8010041a:	9902                	jalr	s2
                num = -(long long)num;
    8010041c:	6782                	ld	a5,0(sp)
    8010041e:	8a66                	mv	s4,s9
    80100420:	40800633          	neg	a2,s0
    80100424:	46a9                	li	a3,10
    80100426:	b53d                	j	80100254 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
    80100428:	03b05163          	blez	s11,8010044a <vprintfmt+0x34c>
    8010042c:	02d00693          	li	a3,45
    80100430:	f6d79de3          	bne	a5,a3,801003aa <vprintfmt+0x2ac>
                p = "(null)";
    80100434:	00000417          	auipc	s0,0x0
    80100438:	0d440413          	addi	s0,s0,212 # 80100508 <memset+0x52>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8010043c:	02800793          	li	a5,40
    80100440:	02800513          	li	a0,40
    80100444:	00140a13          	addi	s4,s0,1
    80100448:	bd6d                	j	80100302 <vprintfmt+0x204>
    8010044a:	00000a17          	auipc	s4,0x0
    8010044e:	0bfa0a13          	addi	s4,s4,191 # 80100509 <memset+0x53>
    80100452:	02800513          	li	a0,40
    80100456:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
    8010045a:	05e00413          	li	s0,94
    8010045e:	b565                	j	80100306 <vprintfmt+0x208>

0000000080100460 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80100460:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80100462:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80100466:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80100468:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8010046a:	ec06                	sd	ra,24(sp)
    8010046c:	f83a                	sd	a4,48(sp)
    8010046e:	fc3e                	sd	a5,56(sp)
    80100470:	e0c2                	sd	a6,64(sp)
    80100472:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80100474:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80100476:	c89ff0ef          	jal	ra,801000fe <vprintfmt>
}
    8010047a:	60e2                	ld	ra,24(sp)
    8010047c:	6161                	addi	sp,sp,80
    8010047e:	8082                	ret

0000000080100480 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    80100480:	4781                	li	a5,0
    80100482:	00003717          	auipc	a4,0x3
    80100486:	b7e73703          	ld	a4,-1154(a4) # 80103000 <SBI_CONSOLE_PUTCHAR>
    8010048a:	88ba                	mv	a7,a4
    8010048c:	852a                	mv	a0,a0
    8010048e:	85be                	mv	a1,a5
    80100490:	863e                	mv	a2,a5
    80100492:	00000073          	ecall
    80100496:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
    80100498:	8082                	ret

000000008010049a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    8010049a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    8010049c:	e589                	bnez	a1,801004a6 <strnlen+0xc>
    8010049e:	a811                	j	801004b2 <strnlen+0x18>
        cnt ++;
    801004a0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    801004a2:	00f58863          	beq	a1,a5,801004b2 <strnlen+0x18>
    801004a6:	00f50733          	add	a4,a0,a5
    801004aa:	00074703          	lbu	a4,0(a4)
    801004ae:	fb6d                	bnez	a4,801004a0 <strnlen+0x6>
    801004b0:	85be                	mv	a1,a5
    }
    return cnt;
}
    801004b2:	852e                	mv	a0,a1
    801004b4:	8082                	ret

00000000801004b6 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    801004b6:	ca01                	beqz	a2,801004c6 <memset+0x10>
    801004b8:	962a                	add	a2,a2,a0
    char *p = s;
    801004ba:	87aa                	mv	a5,a0
        *p ++ = c;
    801004bc:	0785                	addi	a5,a5,1
    801004be:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    801004c2:	fec79de3          	bne	a5,a2,801004bc <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    801004c6:	8082                	ret

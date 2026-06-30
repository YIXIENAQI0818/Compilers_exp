declare i32 @getint()
declare void @putint(i32)
declare void @putch(i32)

@N = constant i32 100
@a = global [100 x i32] zeroinitializer
define i32 @func(i32 %x_p) {
entry:
  %r1 = alloca i32
  store i32 %x_p, i32* %r1
  %r2 = load i32, i32* %r1
  %r3 = icmp eq i32 %r2, 1
  %r4 = zext i1 %r3 to i32
  %r5 = load i32, i32* %r1
  %r6 = icmp eq i32 %r5, 0
  %r7 = zext i1 %r6 to i32
  %r8 = icmp ne i32 %r4, 0
  br i1 %r8, label %label_1, label %label_4
label_4:
  %r9 = icmp ne i32 %r7, 0
  br i1 %r9, label %label_1, label %label_2
label_1:
  ret i32 1
label_2:
  %r10 = load i32, i32* %r1
  %r11 = sub i32 %r10, 1
  %r12 = call i32 @func(i32 %r11)
  %r13 = load i32, i32* %r1
  %r14 = sub i32 %r13, 2
  %r15 = call i32 @func(i32 %r14)
  %r16 = add i32 %r12, %r15
  ret i32 %r16
}

define i32 @main() {
entry:
  %r1 = alloca i32
  store i32 10, i32* %r1
  %r2 = bitcast [100 x i32]* @a to i32*
  %r3 = getelementptr i32, i32* %r2, i32 0
  %r4 = load i32, i32* %r1
  %r5 = add i32 %r4, 2
  %r6 = call i32 @func(i32 %r5)
  store i32 %r6, i32* %r3
  %r7 = bitcast [100 x i32]* @a to i32*
  %r8 = getelementptr i32, i32* %r7, i32 0
  %r9 = load i32, i32* %r8
  call void @putint(i32 %r9)
  ret i32 0
}


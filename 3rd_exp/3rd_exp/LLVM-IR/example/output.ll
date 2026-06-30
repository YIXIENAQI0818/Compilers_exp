declare i32 @getint()
declare void @putint(i32)
declare void @putch(i32)

@N = constant i32 100
@a = global [100 x i32] zeroinitializer

define i32 @func(i32 %x_p) {
entry:
  %r1 = alloca i32
  store i32 %x_p, i32* %r1
  %r3 = load i32, i32* %r1
  %r2 = icmp eq i32 %r3, 1
  br i1 %r2, label %label_6, label %label_3
label_3:
  %r5 = load i32, i32* %r1
  %r4 = icmp eq i32 %r5, 0
  br i1 %r4, label %label_6, label %label_7
label_6:
  ret i32 1
  br label %label_8
label_7:
  %r7 = load i32, i32* %r1
  %r6 = sub i32 %r7, 1
  %r8 = call i32 @func(i32 %r6)
  %r10 = load i32, i32* %r1
  %r9 = sub i32 %r10, 2
  %r11 = call i32 @func(i32 %r9)
  %r12 = add i32 %r8, %r11
  ret i32 %r12
  br label %label_8
label_8:
  ret i32 0
}

define i32 @main() {
entry:
  %r13 = alloca i32
  store i32 10, i32* %r13
  %r14 = bitcast [100 x i32]* @a to i32*
  %r15 = getelementptr i32, i32* %r14, i32 0
  %r17 = load i32, i32* %r13
  %r16 = add i32 %r17, 2
  %r18 = call i32 @func(i32 %r16)
  store i32 %r18, i32* %r15
  %r19 = bitcast [100 x i32]* @a to i32*
  %r20 = getelementptr i32, i32* %r19, i32 0
  %r21 = load i32, i32* %r20
  call void @putint(i32 %r21)
  ret i32 0
}

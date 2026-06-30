declare i32 @getint()
declare void @putint(i32)
declare void @putch(i32)

@N = constant i32 3
@a = global [18 x i32] zeroinitializer
define i32 @f(i32 %x_p) {
entry:
  %r1 = alloca i32
  store i32 %x_p, i32* %r1
  %r2 = load i32, i32* %r1
  %r3 = icmp eq i32 %r2, 1
  %r4 = zext i1 %r3 to i32
  %r5 = icmp ne i32 %r4, 0
  br i1 %r5, label %label_1, label %label_2
label_1:
  ret i32 1
label_2:
  br label %label_3
label_3:
  %r6 = alloca i32
  store i32 1, i32* %r6
  %r7 = load i32, i32* %r1
  %r8 = sub i32 %r7, 1
  %r9 = call i32 @f(i32 %r8)
  %r10 = load i32, i32* %r1
  %r11 = mul i32 %r10, %r9
  store i32 %r11, i32* %r6
  %r12 = load i32, i32* %r6
  ret i32 %r12
}

define i32 @main() {
entry:
  %r1 = call i32 @f(i32 10)
  %r2 = alloca i32
  store i32 %r1, i32* %r2
  %r3 = load i32, i32* %r2
  %r4 = icmp ne i32 %r3, 3628800
  %r5 = zext i1 %r4 to i32
  %r6 = icmp ne i32 %r5, 0
  br i1 %r6, label %label_1, label %label_4
label_4:
  %r7 = load i32, i32* %r2
  %r8 = icmp ne i32 %r7, 0
  br i1 %r8, label %label_1, label %label_2
label_1:
  call void @putint(i32 2333)
  %r9 = load i32, i32* %r2
  %r10 = icmp eq i32 %r9, 0
  %r11 = zext i1 %r10 to i32
  %r12 = icmp ne i32 %r11, 0
  br i1 %r12, label %label_5, label %label_6
label_5:
  %r13 = load i32, i32* %r2
  %r14 = sub i32 %r13, 10
  store i32 %r14, i32* %r2
  br label %label_7
label_6:
  %r15 = load i32, i32* %r2
  %r16 = add i32 %r15, 10
  store i32 %r16, i32* %r2
  br label %label_7
label_7:
  br label %label_3
label_2:
  %r17 = load i32, i32* %r2
  call void @putint(i32 %r17)
  br label %label_3
label_3:
  %r18 = load i32, i32* %r2
  call void @putint(i32 %r18)
  %r19 = alloca i32
  store i32 0, i32* %r19
  %r20 = alloca i32
  store i32 0, i32* %r20
  br label %label_8
label_8:
  %r21 = load i32, i32* %r19
  %r22 = icmp sle i32 %r21, 3
  %r23 = zext i1 %r22 to i32
  %r24 = icmp ne i32 %r23, 0
  br i1 %r24, label %label_9, label %label_10
label_9:
  %r25 = load i32, i32* %r19
  %r26 = icmp eq i32 %r25, 1
  %r27 = zext i1 %r26 to i32
  %r28 = icmp ne i32 %r27, 0
  br i1 %r28, label %label_11, label %label_12
label_11:
  %r29 = load i32, i32* %r19
  %r30 = add i32 %r29, 1
  store i32 %r30, i32* %r19
  br label %label_8
label_12:
  br label %label_13
label_13:
  %r31 = load i32, i32* %r19
  %r32 = icmp eq i32 %r31, 3
  %r33 = zext i1 %r32 to i32
  %r34 = icmp ne i32 %r33, 0
  br i1 %r34, label %label_14, label %label_15
label_14:
  br label %label_10
label_15:
  br label %label_16
label_16:
  %r35 = load i32, i32* %r19
  call void @putint(i32 %r35)
  %r36 = load i32, i32* %r19
  %r37 = add i32 %r36, 1
  store i32 %r37, i32* %r19
  br label %label_8
label_10:
  %r38 = alloca [18 x i32]
  %r39 = bitcast [18 x i32]* %r38 to i32*
  store i32 1, i32* %r19
  %r40 = load i32, i32* %r19
  %r41 = load i32, i32* %r19
  %r42 = add i32 %r40, %r41
  store i32 %r42, i32* %r20
  %r43 = mul i32 0, 6
  %r44 = add i32 %r43, 0
  %r45 = getelementptr i32, i32* %r39, i32 %r44
  %r46 = load i32, i32* %r20
  %r47 = mul i32 %r46, 2
  %r48 = load i32, i32* %r19
  %r49 = add i32 %r48, %r47
  store i32 %r49, i32* %r45
  %r50 = load i32, i32* %r19
  %r51 = mul i32 %r50, 6
  %r52 = load i32, i32* %r20
  %r53 = add i32 %r51, %r52
  %r54 = getelementptr i32, i32* %r39, i32 %r53
  store i32 3, i32* %r54
  %r55 = mul i32 0, 6
  %r56 = add i32 %r55, 0
  %r57 = getelementptr i32, i32* %r39, i32 %r56
  %r58 = load i32, i32* %r57
  call void @putint(i32 %r58)
  %r59 = load i32, i32* %r19
  %r60 = mul i32 %r59, 6
  %r61 = load i32, i32* %r20
  %r62 = add i32 %r60, %r61
  %r63 = getelementptr i32, i32* %r39, i32 %r62
  %r64 = load i32, i32* %r63
  call void @putint(i32 %r64)
  %r65 = load i32, i32* %r19
  %r66 = mul i32 %r65, 6
  %r67 = load i32, i32* %r20
  %r68 = add i32 %r66, %r67
  %r69 = getelementptr i32, i32* %r39, i32 %r68
  %r70 = mul i32 0, 6
  %r71 = add i32 %r70, 0
  %r72 = getelementptr i32, i32* %r39, i32 %r71
  %r73 = load i32, i32* %r69
  %r74 = load i32, i32* %r72
  %r75 = add i32 %r73, %r74
  %r76 = alloca i32
  store i32 %r75, i32* %r76
  %r77 = load i32, i32* %r76
  call void @putint(i32 %r77)
  %r78 = bitcast [18 x i32]* @a to i32*
  %r79 = mul i32 0, 6
  %r80 = add i32 %r79, 0
  %r81 = getelementptr i32, i32* %r78, i32 %r80
  store i32 5, i32* %r81
  %r82 = bitcast [18 x i32]* @a to i32*
  %r83 = mul i32 1, 6
  %r84 = add i32 %r83, 1
  %r85 = getelementptr i32, i32* %r82, i32 %r84
  store i32 2, i32* %r85
  %r86 = bitcast [18 x i32]* @a to i32*
  %r87 = mul i32 0, 6
  %r88 = add i32 %r87, 0
  %r89 = getelementptr i32, i32* %r86, i32 %r88
  %r90 = load i32, i32* %r89
  call void @putint(i32 %r90)
  %r91 = bitcast [18 x i32]* @a to i32*
  %r92 = mul i32 1, 6
  %r93 = add i32 %r92, 1
  %r94 = getelementptr i32, i32* %r91, i32 %r93
  %r95 = load i32, i32* %r94
  call void @putint(i32 %r95)
  %r96 = bitcast [18 x i32]* @a to i32*
  %r97 = mul i32 1, 6
  %r98 = add i32 %r97, 1
  %r99 = getelementptr i32, i32* %r96, i32 %r98
  %r100 = call i32 @getint()
  store i32 %r100, i32* %r99
  %r101 = bitcast [18 x i32]* @a to i32*
  %r102 = mul i32 1, 6
  %r103 = add i32 %r102, 1
  %r104 = getelementptr i32, i32* %r101, i32 %r103
  %r105 = load i32, i32* %r104
  call void @putint(i32 %r105)
  ret i32 0
}


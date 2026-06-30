declare i32 @getint()
declare void @putint(i32)
declare void @putch(i32)

@N = constant i32 10
@a = global [10 x i32] zeroinitializer
@b = global [10 x i32] zeroinitializer
@c = global [10 x i32] zeroinitializer
define i32 @main() {
entry:
  %r1 = alloca i32
  %r2 = alloca i32
  %r3 = call i32 @getint()
  store i32 %r3, i32* %r1
  %r4 = call i32 @getint()
  store i32 %r4, i32* %r2
  %r5 = alloca i32
  store i32 0, i32* %r5
  br label %label_1
label_1:
  %r6 = load i32, i32* %r5
  %r7 = load i32, i32* %r1
  %r8 = icmp slt i32 %r6, %r7
  %r9 = zext i1 %r8 to i32
  %r10 = icmp ne i32 %r9, 0
  br i1 %r10, label %label_2, label %label_3
label_2:
  %r11 = bitcast [10 x i32]* @a to i32*
  %r12 = load i32, i32* %r5
  %r13 = getelementptr i32, i32* %r11, i32 %r12
  %r14 = call i32 @getint()
  store i32 %r14, i32* %r13
  %r15 = load i32, i32* %r5
  %r16 = add i32 %r15, 1
  store i32 %r16, i32* %r5
  br label %label_1
label_3:
  store i32 0, i32* %r5
  br label %label_4
label_4:
  %r17 = load i32, i32* %r5
  %r18 = load i32, i32* %r2
  %r19 = icmp slt i32 %r17, %r18
  %r20 = zext i1 %r19 to i32
  %r21 = icmp ne i32 %r20, 0
  br i1 %r21, label %label_5, label %label_6
label_5:
  %r22 = bitcast [10 x i32]* @b to i32*
  %r23 = load i32, i32* %r5
  %r24 = getelementptr i32, i32* %r22, i32 %r23
  %r25 = call i32 @getint()
  store i32 %r25, i32* %r24
  %r26 = load i32, i32* %r5
  %r27 = add i32 %r26, 1
  store i32 %r27, i32* %r5
  br label %label_4
label_6:
  %r28 = alloca i32
  store i32 0, i32* %r28
  store i32 0, i32* %r5
  br label %label_7
label_7:
  %r29 = load i32, i32* %r5
  %r30 = load i32, i32* %r1
  %r31 = icmp slt i32 %r29, %r30
  %r32 = zext i1 %r31 to i32
  %r33 = icmp ne i32 %r32, 0
  br i1 %r33, label %label_8, label %label_9
label_8:
  store i32 0, i32* %r28
  br label %label_10
label_10:
  %r34 = load i32, i32* %r28
  %r35 = load i32, i32* %r2
  %r36 = icmp slt i32 %r34, %r35
  %r37 = zext i1 %r36 to i32
  %r38 = icmp ne i32 %r37, 0
  br i1 %r38, label %label_11, label %label_12
label_11:
  %r39 = bitcast [10 x i32]* @a to i32*
  %r40 = load i32, i32* %r5
  %r41 = getelementptr i32, i32* %r39, i32 %r40
  %r42 = bitcast [10 x i32]* @b to i32*
  %r43 = load i32, i32* %r28
  %r44 = getelementptr i32, i32* %r42, i32 %r43
  %r45 = load i32, i32* %r41
  %r46 = load i32, i32* %r44
  %r47 = mul i32 %r45, %r46
  %r48 = alloca i32
  store i32 %r47, i32* %r48
  %r49 = load i32, i32* %r5
  %r50 = load i32, i32* %r28
  %r51 = add i32 %r49, %r50
  %r52 = bitcast [10 x i32]* @c to i32*
  %r53 = getelementptr i32, i32* %r52, i32 %r51
  %r54 = load i32, i32* %r5
  %r55 = load i32, i32* %r28
  %r56 = add i32 %r54, %r55
  %r57 = bitcast [10 x i32]* @c to i32*
  %r58 = getelementptr i32, i32* %r57, i32 %r56
  %r59 = load i32, i32* %r58
  %r60 = load i32, i32* %r48
  %r61 = add i32 %r59, %r60
  store i32 %r61, i32* %r53
  %r62 = load i32, i32* %r28
  %r63 = add i32 %r62, 1
  store i32 %r63, i32* %r28
  br label %label_10
label_12:
  %r64 = load i32, i32* %r5
  %r65 = add i32 %r64, 1
  store i32 %r65, i32* %r5
  br label %label_7
label_9:
  store i32 0, i32* %r5
  br label %label_13
label_13:
  %r66 = load i32, i32* %r1
  %r67 = load i32, i32* %r2
  %r68 = add i32 %r66, %r67
  %r69 = sub i32 %r68, 1
  %r70 = load i32, i32* %r5
  %r71 = icmp slt i32 %r70, %r69
  %r72 = zext i1 %r71 to i32
  %r73 = icmp ne i32 %r72, 0
  br i1 %r73, label %label_14, label %label_15
label_14:
  %r74 = bitcast [10 x i32]* @c to i32*
  %r75 = load i32, i32* %r5
  %r76 = getelementptr i32, i32* %r74, i32 %r75
  %r77 = load i32, i32* %r76
  call void @putint(i32 %r77)
  %r78 = load i32, i32* %r5
  %r79 = add i32 %r78, 1
  store i32 %r79, i32* %r5
  br label %label_13
label_15:
  ret i32 0
}


declare i32 @getint()
declare void @putint(i32)
declare void @putch(i32)

define i32 @main() {
entry:
  %r1 = alloca [36 x i32]
  %r2 = bitcast [36 x i32]* %r1 to i32*
  %r3 = alloca i32
  store i32 1, i32* %r3
  %r4 = alloca i32
  store i32 1, i32* %r4
  br label %label_1
label_1:
  %r5 = load i32, i32* %r3
  %r6 = icmp slt i32 %r5, 5
  %r7 = zext i1 %r6 to i32
  %r8 = load i32, i32* %r4
  %r9 = icmp slt i32 %r8, 5
  %r10 = zext i1 %r9 to i32
  %r11 = icmp ne i32 %r7, 0
  br i1 %r11, label %label_4, label %label_3
label_4:
  %r12 = icmp ne i32 %r10, 0
  br i1 %r12, label %label_2, label %label_3
label_2:
  %r13 = load i32, i32* %r3
  %r14 = mul i32 %r13, 6
  %r15 = load i32, i32* %r4
  %r16 = add i32 %r14, %r15
  %r17 = getelementptr i32, i32* %r2, i32 %r16
  %r18 = load i32, i32* %r3
  %r19 = load i32, i32* %r4
  %r20 = add i32 %r18, %r19
  store i32 %r20, i32* %r17
  %r21 = load i32, i32* %r4
  %r22 = add i32 %r21, 1
  store i32 %r22, i32* %r4
  br label %label_1
label_3:
  br label %label_5
label_5:
  %r23 = load i32, i32* %r3
  %r24 = icmp slt i32 %r23, 5
  %r25 = zext i1 %r24 to i32
  %r26 = load i32, i32* %r4
  %r27 = icmp slt i32 %r26, 6
  %r28 = zext i1 %r27 to i32
  %r29 = icmp ne i32 %r25, 0
  br i1 %r29, label %label_8, label %label_7
label_8:
  %r30 = icmp ne i32 %r28, 0
  br i1 %r30, label %label_6, label %label_7
label_6:
  %r31 = load i32, i32* %r3
  %r32 = mul i32 %r31, 6
  %r33 = load i32, i32* %r4
  %r34 = add i32 %r32, %r33
  %r35 = getelementptr i32, i32* %r2, i32 %r34
  %r36 = load i32, i32* %r3
  %r37 = load i32, i32* %r4
  %r38 = sub i32 %r36, %r37
  store i32 %r38, i32* %r35
  %r39 = load i32, i32* %r3
  %r40 = add i32 %r39, 1
  store i32 %r40, i32* %r3
  br label %label_5
label_7:
  %r41 = mul i32 1, 6
  %r42 = add i32 %r41, 1
  %r43 = getelementptr i32, i32* %r2, i32 %r42
  %r44 = mul i32 1, 6
  %r45 = add i32 %r44, 4
  %r46 = getelementptr i32, i32* %r2, i32 %r45
  %r47 = load i32, i32* %r43
  %r48 = load i32, i32* %r46
  %r49 = add i32 %r47, %r48
  %r50 = mul i32 4, 6
  %r51 = add i32 %r50, 5
  %r52 = getelementptr i32, i32* %r2, i32 %r51
  %r53 = load i32, i32* %r52
  %r54 = add i32 %r49, %r53
  call void @putint(i32 %r54)
  ret i32 0
}


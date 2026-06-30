declare i32 @getint()
declare void @putint(i32)
declare void @putch(i32)

define i32 @main() {
entry:
  %r1 = alloca i32
  %r2 = alloca i32
  %r3 = call i32 @getint()
  store i32 %r3, i32* %r1
  %r4 = call i32 @getint()
  store i32 %r4, i32* %r2
  %r5 = load i32, i32* %r1
  %r6 = load i32, i32* %r2
  %r7 = add i32 %r5, %r6
  %r8 = alloca i32
  store i32 %r7, i32* %r8
  %r9 = load i32, i32* %r8
  call void @putint(i32 %r9)
  ret i32 0
}



BEGIN {
  FS = "...XXXXRANDOM"
  skip = 0
  srand()
  counter = int( rand() * 10000 )
  rando = ""
}

/NEWXXXXRANDOM/ {
  system("openssl passwd rnd | sed \"s,[\\/\\.],X,g\" | sed \"s,^[0-9a-z],X,\" > /tmp/.NEWRANDOMXXXX")
  rando = sprintf("%d", rand() * 1000000)
  skip = 1
  printf("%s",$1)
  system("printf X`cat /tmp/.NEWRANDOMXXXX`")
  printf("X%d%s",counter, rando)
  print $2
  counter = counter + 123
}

/XXXXXXXRANDOM/ {
  skip = 1
  printf("%s",$1)
  system("printf X`cat /tmp/.NEWRANDOMXXXX`")
  printf("X%d%d",counter, rando)
  print $2
}

{ if (skip == 1) {
    skip = 0
  } else {
    print $0
  }
}


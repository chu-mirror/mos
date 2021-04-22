# MOS - My OS

I decide to write an operating system to learn something...

It's still at beginning, and I'm not sure how to complete it for now,
just put a TODO list here to remind myself.

If you want to compile my code, you need to install __noweb__ first,
```
$ make all 	# compile kernel
$ make qemu	# start qemu
$ make doc	# generate a pdf document

$ make clean	# delete temporary files
$ make clobber	# delete all files except source code
```

## TODO

1. driver of UART, print something(maybe _Hello world!_).
	- print "Hel" successfully

2. log system, record(wait for file system) or print debug information.

3. rewrite all codes in a better way.
	- well done

4. build concept of process 

5. spinlock

6. implement task

7. handle interrupt

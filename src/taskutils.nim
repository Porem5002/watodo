import std/terminal
import strutils

type task* = object
    id*: uint
    done*: bool
    text*: string

type taskList* = object
    capacity*: Natural
    size*: Natural
    data*: ptr task

const LIST_DEF_CAP = 10

proc newTaskList*(): taskList =
    var list = taskList()
    list.capacity = LIST_DEF_CAP
    list.size = 0
    list.data = cast[ptr task](alloc0(sizeof(task)*list.capacity))
    return list

proc eptr*(list: var taskList, i: Natural): ptr task =
    # Equivalent to '&list.data[list.size]' in C
    return cast[ptr task](cast[ByteAddress](list.data) +% i * sizeof(task))

proc eget*(list: var taskList, i: Natural): task =
    return list.eptr(i)[]

proc eset*(list: var taskList, i: Natural, t: task) =
    list.eptr(i)[] = t

proc add*(list: var taskList, t: task) =
    if list.size >= list.capacity:
        var new_cap = list.capacity*2 
        list.data = cast[ptr task](realloc0(list.data, list.capacity*sizeof(task), new_cap*sizeof(task)))
        list.capacity = new_cap

    list.eset(list.size, t)
    list.size += 1

proc clear*(list: var taskList) =
    list.size = 0

iterator unroll*(list: var taskList): task =
    for i in countup(0, list.size-1):
        yield list.eget(i)

iterator unrollrefs*(list: var taskList): ptr task =
    for i in countup(0, list.size-1):
        yield list.eptr(i)

proc show*(t: task) =
    if t.done:
        stdout.styledWrite("--", fgGreen, "DONE: ")
    else:
        stdout.styledWrite("--", fgBlue, "TODO: ")
    stdout.styledWrite(resetStyle, "ID:", $(t.id), " => ")
    stdout.styledWrite(fgYellow, t.text)
    stdout.styledWriteLine(resetStyle, " --")
    stdout.resetAttributes()

proc writeToFile*(t: task, f: File) =
    f.write "i", $(t.id), "|"
    f.write "d", $(if t.done: 1 else: 0), "|"
    f.writeLine "t", t.text

proc readFromFile*(f: File): task =
    var t = task()
    var c = f.readChar() # read 'i'
    var idStr = ""
    while true:
        var c = f.readChar()
        if c == '|':
            break
        idStr = idStr & c
    t.id = idStr.parseUInt

    c = f.readChar() # read 'd'
    t.done = f.readChar() == '1'
    c = f.readChar() # read '|'

    c = f.readChar() # read 't'
    t.text = f.readLine()
    return t

proc toFile*(list: var taskList, f: File) =
    for t in list.unroll:
        t.writeToFile(f)

proc fromFile*(list: var taskList, f: File) =
    list.clear()
    while not endOfFile(f):
        var t = f.readFromFile()
        list.add(t)
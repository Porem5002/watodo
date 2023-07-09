import std/terminal
import std/sugar
import strutils
import taskutils
import os

const WATUDO_DIR = ".watudo"
const WATUDO_TASKS_FILE = WATUDO_DIR & "\\tasks.txt"

var tasks = newTaskList()

proc isInit() : bool = dirExists(WATUDO_DIR)

proc commandInit() =
    if isInit():
        stdout.writeLine("watudo is already initialized!")
    else:
        createDir(WATUDO_DIR)

proc commandShow() =
    if tasks.size == 0:
        stdout.writeLine("(NO TASKS)")
        return
    for t in tasks.unroll:
        t.show

proc commandBeginTask() =
    var t = task()
    t.done = false
    t.id = uint(tasks.size)
    stdout.writeLine("Write a name/description for the task: ")
    t.text = stdin.readLine()
    tasks.add(t)
    
    var f = open(WATUDO_TASKS_FILE, fmAppend)
    t.writeToFile(f)
    f.close()

    stdout.writeLine("The new task was registered successfully!")
    t.show

proc commandFinishTask() =
    stdout.writeLine("Write the ID of the task to finish: ")
    var id = parseUInt(stdin.readLine())
    var pt: ptr task = nil

    for t in tasks.unrollrefs:
        if t.id == id:
            pt = t

    if pt == nil:
        stdout.writeLine("There is no task with ID ", id, "!")
        return

    if pt.done:
        stdout.writeLine("The task with ID ", id, " was already finished!")
        return

    pt.done = true

    var f = open(WATUDO_TASKS_FILE, fmWrite)
    tasks.toFile(f)
    f.close()

    stdout.writeLine("The task was finished successfully!")
    pt[].show

proc main(): void =
    var loopcond : proc (): bool

    if isatty(stdin):
        loopcond = () => true
    else:
        loopcond = () => not endOfFile(stdin)

    if isInit() and fileExists(WATUDO_TASKS_FILE):
        var f = open(WATUDO_TASKS_FILE, fmRead)
        tasks.fromFile(f)
        f.close()

    while loopcond():
        stdout.write(">")
        var command = stdin.readLine() 

        if command == "init":
            commandInit()
            continue

        if command == "quit":
            quit(QuitSuccess)
        
        if not isInit():
            stdout.writeLine("watudo is not initialized for this directory, run the command 'init' to initialize it!")
            continue
    
        case command:
            of "show":
                commandShow()
            of "begin":
                commandBeginTask()
            of "finish":
                commandFinishTask()
            else:
                stdout.writeLine("\'", command, "\' is not recongined as a valid command!");

when isMainModule:
    main()
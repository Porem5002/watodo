import strutils
import taskutils
import os

when defined(windows):
    const PathSlash = "\\"
else:
    const PathSlash = "/"

const WATODO_DIR = ".watodo"
const WATODO_TASKS_FILE = WATODO_DIR & PathSlash & "tasks.txt"

proc isInit() : bool = dirExists(WATODO_DIR) and fileExists(WATODO_TASKS_FILE)

proc commandInit() =
    if isInit():
        stdout.writeLine("watodo is already initialized!")
    else:
        createDir(WATODO_DIR)
        var f = open(WATODO_TASKS_FILE, fmWrite)
        f.close()

proc commandShow() =
    var f = open(WATODO_TASKS_FILE, fmRead)
    defer: f.close()

    var tasks = tasksFromFile(f)
    defer: tasks.free()

    if tasks.size == 0:
        stdout.writeLine("(NO TASKS)")
        return

    for t in tasks.unroll:
        t.show

proc commandBeginTask() =
    var f = open(WATODO_TASKS_FILE, fmReadWriteExisting)
    defer: f.close()

    var tasks = tasksFromFile(f)
    defer: tasks.free()

    var t = task(done: false, id: uint(tasks.size))
    stdout.write("Write a name/description for the task: ")
    t.text = stdin.readLine()
    t.writeToFile(f)
    
    stdout.writeLine("The new task was registered successfully!")
    t.show

proc commandFinishTask() =
    var f1 = open(WATODO_TASKS_FILE, fmReadWriteExisting)
    defer: f1.close()

    var tasks = tasksFromFile(f1)
    defer: tasks.free()

    stdout.write("Write the ID of the task to finish: ")
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

    var f2 = open(WATODO_TASKS_FILE, fmWrite)
    defer: f2.close
    tasksToFile(tasks, f2)

    stdout.writeLine("The task was finished successfully!")
    pt[].show

proc main(): void =
    if paramCount() == 0:
        quit(QuitSuccess)

    var command = paramStr(1)

    if command == "init":
        commandInit()
        return
    
    if not isInit():
        stdout.writeLine("watodo is not initialized for this directory!")
        return

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
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

proc commandBeginTask(desc: string): task =
    var f = open(WATODO_TASKS_FILE, fmReadWriteExisting)
    defer: f.close()

    var tasks = tasksFromFile(f)
    defer: tasks.free()

    var t = task(done: false, id: uint(tasks.size), text: desc)
    t.writeToFile(f)
    return t

type status_enum = enum success, alreadyDone, notFound 
type status = object
    e: status_enum
    t: task
proc commandRemoveTask(id: uint): status =
    var f1 = open(WATODO_TASKS_FILE, fmReadWriteExisting)
    defer: f1.close()

    var tasks = tasksFromFile(f1)
    defer: tasks.free()

    var found = false
    var index: Natural = 0

    for t in tasks.unrollrefs:
        if t.id == id:
            found = true
            break
        index += 1

    if not found:
        return status(e: notFound, t: task())

    tasks.remat(index)

    var f2 = open(WATODO_TASKS_FILE, fmWrite)
    defer: f2.close
    tasksToFile(tasks, f2)

    return status(e: success, t: task())

proc commandFinishTask(id: uint): status =
    var f1 = open(WATODO_TASKS_FILE, fmReadWriteExisting)
    defer: f1.close()

    var tasks = tasksFromFile(f1)
    defer: tasks.free()

    var pt: ptr task = nil

    for t in tasks.unrollrefs:
        if t.id == id:
            pt = t
            break

    if pt == nil:
        return status(e: notFound, t: task())

    if pt.done:
        return status(e: alreadyDone, t: task())

    pt.done = true

    var f2 = open(WATODO_TASKS_FILE, fmWrite)
    defer: f2.close
    tasksToFile(tasks, f2)

    return status(e: success, t: pt[])

proc askUserToProceed() =
    stdout.write("Are you sure you want to execute the command?(y/n) ")
    var c = stdin.readChar()
    if c != 'y' and c != 'Y':
        quit(QuitSuccess)

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
            if(paramCount() < 2):
                stdout.writeLine("Error: Command ", command," expected the description of the task to be passed as it's first and only argument!")
                quit(QuitFailure)
            if(paramCount() > 2):
                stdout.writeLine("Error: To many arguments passed to command ", command,"!")
                quit(QuitFailure)
            askUserToProceed()
            var t = commandBeginTask(paramStr(2))
            stdout.writeLine("The task was registered successfully!")
            t.show
        of "remove":
            if(paramCount() < 2):
                stdout.writeLine("Error: Command ", command," expected the description of the task to be passed as it's first and only argument!")
                quit(QuitFailure)
            if(paramCount() > 2):
                stdout.writeLine("Error: To many arguments passed to command ", command,"!")
                quit(QuitFailure)
            
            var id: uint = 0

            try:
                id = parseUInt(paramStr(2))
            except ValueError:
                stdout.writeLine("Error: Argument 1 with value '", paramStr(2),"' cannot be converted to a not a valid ID value!")
                quit(QuitFailure)
            
            askUserToProceed()
            var status = commandRemoveTask(id)
            
            case status.e:
                of success:
                    stdout.writeLine("The task was removed succesfully!")
                    quit(QuitSuccess)
                of notFound:
                    stdout.writeLine("Error: No task with the given ID exists!")
                    quit(QuitFailure)
                else:
                    discard

        of "finish":
            if(paramCount() < 2):
                stdout.writeLine("Error: Command ", command," expected the description of the task to be passed as it's first and only argument!")
                quit(QuitFailure)
            if(paramCount() > 2):
                stdout.writeLine("Error: To many arguments passed to command ", command,"!")
                quit(QuitFailure)

            var id: uint = 0

            try:
                id = parseUInt(paramStr(2))
            except ValueError:
                stdout.writeLine("Error: Argument 1 with value '", paramStr(2),"' cannot be converted to a not a valid ID value!")
                quit(QuitFailure)

            askUserToProceed()
            var status = commandFinishTask(id)

            case status.e:
                of success:
                    stdout.writeLine("The task was finished succesfully!")
                    status.t.show
                    quit(QuitSuccess)
                of alreadyDone:
                    stdout.writeLine("The task was already marked as finished!")
                    quit(QuitSuccess)
                of notFound:
                    stdout.writeLine("Error: No task with the given ID exists!")
                    quit(QuitFailure)
        else:
            stdout.writeLine("Error: ", command, " is not a valid command!");
            quit(QuitFailure)

when isMainModule:
    main()
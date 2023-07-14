# watodo

![program demonstration](imgs/main.png)

A little program that I made in [nim](https://nim-lang.org/) to try out the language.

This is a todo list CLI program that allows the user to create tasks and later mark them as done.

## Build

To build the project on your own machine, make sure you have nim installed correctly and available in your PATH environment variable.

After that you run the following command:
```
$ nimble build 
```
With this command run, a new executable called 'watodo' should have been created, this is the compiled program.  

Finally, it would be a good idea to make sure the executable is available in your PATH environment variable, to make it easier to use in any directory of your computer.

## Usage
The program contains a few simple commands:
- init
- show
- begin
- remove
- finish

### 'init' command
Initializes a new todo list for the current directory (there can only be 1 todo list per directory) 

### 'show' command
Shows all the registered tasks, displaying their __status__(TODO or DONE), __ID__ and the __description__ of the task.

### 'begin' command
Registers a new task into the todo list.

When using this command you will need to provide a __description__ for the task, and you can do that like this:
```bash
$ watodo begin "Task Description"
```
So if you want to create a task with the __description__ "Fix Bugs", this is the command you will need to type:
```bash
$ watodo begin "Fix Bugs"
```

### 'remove' command
Removes a task from the todo list.

When using this command you will need to specify the __ID__ of the task that you want to remove, this is the way to do it:
```bash
$ watodo remove ID
```
So if you want to remove a task that has __ID__ of 2, you do it like this:
```bash
$ watodo remove 2
```

### 'finish' command
Marks a task as finished.

When using this command you will need to specify the __ID__ of the task that you want to finish, this is the way to do it:
```bash
$ watodo finish ID
```
So if you want to finish a task that has __ID__ of 3, you do it like this:
```bash
$ watodo finish 3
```

## License
[MIT](https://choosealicense.com/licenses/mit/)
# PandaHook API Guide
This guide aims to document and specify the API of PandaHook when used as a Node library.

## create (options)
This function creates a "bare" repository on the hook-server.  The repository consists solely of what is usually within the `.git` folder of a regular repository.  This function also creates a git alias for the remote repository under the name "hook".

### options - [See Schema][1]

## destroy (options)
This function is the converse of `create`.  It deletes the bare repository bearing the specified name, as well as its standard-repo copy, if present.  This function also removes the git alias "hook".

### options - [See Schema][2]

## push (options)
This function places a githook script into the remote "bare" repository.  It is placed into the `hooks` directory and made executable.  If the target repo does not exist, this function calls `create()` and then `push()` again.

### options - [See Schema][3]

## rm (options)
This function is the converse of `push`.  It removes the specified githook script from the remote repository.

### options - [See Schema][4]


[1]:https://github.com/pandastrike/panda-hook/blob/master/schema/create.json
[2]:https://github.com/pandastrike/panda-hook/blob/master/schema/destroy.json
[3]:https://github.com/pandastrike/panda-hook/blob/master/schema/push.json
[4]:https://github.com/pandastrike/panda-hook/blob/master/schema/rm.json

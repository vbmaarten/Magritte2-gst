Symbol extend [
    beginsWithSubCollection: aSymbol [
        ^(self startsWith: aSymbol).
    ]
]

Object subclass: FileDirectory [
    | dir |

    FileDirectory class >> default [
        ^self on: Directory home.
    ]

    FileDirectory class >> on: aDirectory [
        | fd |
        fd := FileDirectory new.
        fd setDir: aDirectory.
        ^fd.
    ]

    setDir: aDirectory [
        dir := aDirectory.
    ]

    directoryNamed: aDirectory [
        dir := dir / aDirectory.
    ]

    assureExistence [
        dir exists ifFalse: [
            dir := Directory create: dir name.
        ]
    ]

    fileExists: aFile [
        (aFile first = $/) ifTrue: [
            ^(File name: aFile) exists.    
        ] ifFalse: [
            ^(dir / aFile) exists.
        ]
    ]

    exists [
        ^dir exists.
    ]

    recursiveDelete [
        dir recursiveDelete.
    ]

    forceNewFileNamed: aFile [
        | file |

        file := File name: aFile.
        file exists ifTrue: [
            file remove.
        ]. 

        file touch.
        ^file.
    ]

    containingDirectory [
        | path |
        path := dir asString tokenize: '/'.
        path := path copyFrom: 1 to: path size - 1.
        path := File name: (path join: '/').
        ^FileDirectory on: path.
    ]

    entries [
        | array |
        array := Array new: (dir filesMatching: '*') size.
        (dir filesMatching: '*') doWithIndex: [ :file :i |
            | description |
            description := Array new: 5.
            description at: 1 put: file name. 
            description at: 1 put: file creationTime. 
            description at: 1 put: file lastModifyTime. 
            description at: 1 put: file mode. 
            description at: 1 put: file size. 

            array at: i put: description.
        ]   
    ]

    isEmpty [
        ^(dir filesMatching: '*') size > 2.
    ]

]

File extend [
    binary []

    nextPutAll: aString [
        | stream |
        stream := self writeStream.        
        aString do: [ :character |
            stream nextPut: (Character codePoint: character).
            ].

        stream close.
    ]

    close []

    recursiveDelete [
        self isDirectory ifTrue: [
                (self filesMatching: '*') do: [ :file |
                    "to exclude /. and /.."
                    (self name size >= file name size) ifFalse: [
                        file recursiveDelete.
                    ].
                ].
                self remove.
        ] ifFalse: [
            self remove.
        ].
    ]
]


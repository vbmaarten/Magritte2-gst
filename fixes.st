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
        | array dirContent |
        dirContent := dir filesMatching: '*'.
        array := Array new: dirContent size.
        dirContent doWithIndex: [ :file :i |
            | description |
            description := Array new: 5.
            description at: 1 put: file name. 
            description at: 2 put: file creationTime. 
            description at: 3 put: file lastModifyTime. 
            description at: 4 put: file mode. 
            description at: 5 put: file size. 

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
                    (file = self or: [file = self parent]) ifFalse: [
                        file recursiveDelete.
                    ].
                ].
                self remove.
        ] ifFalse: [
            self remove.
        ].
    ]
]

Object subclass: Color [
    | r g b a |

    Color class >> blue [
        ^self r: 0 g: 0 b: 255.
    ]

    Color class >> green [
        ^self r: 0 g: 255 b: 0.
    ]

    Color class >> red [
        ^self r: 255 g: 0 b: 0.
    ]
   
    Color class >> r: red g: green b: blue [
        | color |
        color := self new.
        color r: red g: green b: blue.
        ^color.
    ]

    Color class >> fromString: aString [
        "Should accept strings such as:
        white
        blue
        #FF0000
        Empty string = white    
        "   

        ^Color r: 255 g: 255 b:255.
    ]


    r: red g: green b: blue [
        r := red.
        g := green.
        b := blue.
        a := 255.
    ]

    red [
        ^r.
    ]

    green [
        ^g.
    ]

    blue [
        ^b.
    ]

]

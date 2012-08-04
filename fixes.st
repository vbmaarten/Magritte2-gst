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

DateTime subclass: DateAndTime [
]

String extend [
    includesSubString: aString [
        ^(self indexOfRegex: aString) size > 0.
    ]

    includesSubstring: aString caseSensitive: caseSensitive [
        caseSensitive ifTrue: [
            ^self includesSubString: aString.
        ] ifFalse: [
            ^self asLowercase includesSubString: aString asLowercase.
        ].
    ]

    caseInsensitiveLessOrEqual: aString [
        ^true.
    ]
]

DateTime subclass: TimeStamp [
    date [
        ^self asDate
    ]

    time [
        ^self asTime
    ]
]

Collection extend [
    intersection: aCollection [
        "Code coppied from Squeak"
        ^self select: [:each | aCollection includes: each]
    ]
]

String extend [
    padLeft: aCharacter size: size [
        | result |
        result := self copy.
        (self size < size) ifTrue: [
            1 to: (size - self size) do: [ :i | 
                result := (aCharacter asString, result).
            ].
        ].
        ^result.
    ]
]

Time extend [
    print24: print24 showSeconds: showSeconds on: aStream[
        | result hour |
        print24 ifTrue: [
            result := (self hours asString padLeft: $0 size: 2)
        ] ifFalse: [
            hour := self hours.
            (hour > 12) ifTrue: [ hour := hour - 12 ].
            result := (hour asString padLeft: $0 size: 2).
        ].

        result := result, ':',(self minutes asString padLeft: $0 size: 2).
        showSeconds ifTrue: [
            result := (result, ':',(self seconds asString padLeft: $0 size: 2)).
        ].

        result print: self on: aStream.
    ]
]

Collection extend [
    reduce: aBlock [
        | result |
        result := self first. 
        (self size > 1) ifTrue: [
            2 to: (self size) do: [ :i |
               result := aBlock value: result value: (self at: i). 
            ]
        ].

        ^result
    ]
]

Behavior extend [
    "Code taken from StartCompiler.st"
    evaluatorClass [
        ^STInST.GSTFileInParser
    ]

    parserClass [
        ^STInST.RBBracketedMethodParser
    ]
]

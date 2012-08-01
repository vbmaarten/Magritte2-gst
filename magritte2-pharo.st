PackageLoader fileInPackage: 'Grease'.

BlockClosure extend [

    magritteDynamicObject [
	"Answer an object that will automatically evaluate the receiver when it receives a message. It will eventually pass the message to the resulting object. Use with caution, for details see *MADynamicObject*."

	<category: '*magritte-pharo-model'>
	^Magritte2.MADynamicObject on: self
    ]

]



Grease.GRPackage class extend [

    magrittePharoModel [
	<category: '*magritte-pharo-model'>
	^(self new)
	    name: 'Magritte-Pharo-Model';
	    addDependency: 'Magritte-Model';
	    url: #magritteUrl;
	    yourself
    ]

]



BlockContext extend [

    magritteDynamicObject [
	"Answer an object that will automatically evaluate the receiver when it receives a message. It will eventually pass the message to the resulting object. Use with caution, for details see *MADynamicObject*."

	<category: '*magritte-pharo-model'>
	^Magritte2.MADynamicObject on: self
    ]

]



MAFileModel subclass: MAExternalFileModel [
    | location |
    
    <comment: 'I manage the file-data I represent on the file-system. From the programmer this looks the same as if the file would be in memory (==*MAMemoryFileModel*==), as it is transparently loaded and written out as necessary.- The ==#baseDirectory== is the place where Magritte puts its file-database. Keep this value to nil to make it default to a subdirectory next to the Squeak image.- The ==#baseUrl== is a nice optimization to allow Apache (or any other Web Server) to directly serve the files. ==#baseUrl== is an absolute URL-prefix that is used to generate the path to the file. If you have specified one the file data does not go trough the image anymore, but instead is directly served trough the properly configured Web Server.The files are currently stored using the following scheme:=/files/9d/bsy8kyp45g0q7blphknk48zujap2wd/earthmap1k.jpg=1     2   3                              4#Is the #baseDirectory as specified in the settings.#Are 256 directories named ''00'' to ''ff'' to avoid having thousands of files in the same directory. Unfortunately this leads to problems with the Squeak file primitives and some filesystems don''t handle that well. This part is generated at random.#This is a secure id, similar to the Seaside session key. It is generated at random and provides a security system that even works trough Apache (you have to disable directory listings of course): if you don''t know the file-name you cannot access the file.#This is the original file-name. Subclasses might want to store other cached versions of the same file there, for example resized images, etc.'>
    <category: 'Magritte-Pharo-Model'>

    MAExternalFileModel class [
	| baseDirectory baseUrl |
	
    ]

    MAExternalFileModel class >> baseDirectory [
	<category: 'accessing'>
	^baseDirectory ifNil: [FileDirectory default directoryNamed: 'files']
    ]

    MAExternalFileModel class >> baseDirectory: aStringOrDirectory [
	"Defines the base-directory where the files are stored. If this value is set to nil, it default to a subdirectory of of the current image-location."

	<category: 'accessing'>
	baseDirectory := aStringOrDirectory isString 
		    ifTrue: [FileDirectory on: aStringOrDirectory]
		    ifFalse: [aStringOrDirectory]
    ]

    MAExternalFileModel class >> baseDirectoryPath [
	<category: 'accessing'>
	^self baseDirectory pathName
    ]

    MAExternalFileModel class >> baseDirectoryPath: aString [
	<category: 'accessing'>
	self baseDirectory: (FileDirectory on: aString)
    ]

    MAExternalFileModel class >> baseUrl [
	<category: 'accessing'>
	^baseUrl
    ]

    MAExternalFileModel class >> baseUrl: aString [
	"Defines the base-URL where the files are served from, when using an external web server. This setting is left to nil by default, causing the files to be served trough the image."

	<category: 'accessing'>
	baseUrl := aString isNil 
		    ifFalse: 
			[aString last = $/ ifFalse: [aString] ifTrue: [aString copyUpToLast: $/]]
    ]

    MAExternalFileModel class >> garbageCollect [
	"Remove obsolete files from the file-system that do not have a counterpart in memory anymore. This method has to be called manually and is not intended to be portable."

	<category: 'public'>
	| mark sweep |
	mark := self allInstances collect: [:each | each directory pathName].
	sweep := Array with: self baseDirectory.
	self locationDefinition do: 
		[:definition | 
		sweep := sweep gather: 
				[:directory | 
				directory entries isEmpty ifTrue: [directory recursiveDelete].
				(directory directoryNames select: [:each | each size = definition first]) 
				    collect: [:each | directory directoryNamed: each]]].
	sweep 
	    do: [:directory | (mark includes: directory pathName) ifFalse: [directory recursiveDelete]]
    ]

    MAExternalFileModel class >> initialize [
	<category: 'initialization'>
	baseDirectory := baseUrl := nil
    ]

    MAExternalFileModel class >> locationDefinition [
	<category: 'initialization'>
	^#(#(2 '63450af8d9c2e17b') #(30 'iaojv41bw67e0tud5m9rgplqfy8x3cs2kznh'))
    ]

    = anObject [
	<category: 'comparing'>
	^super = anObject and: [self location = anObject location]
    ]

    baseDirectory [
	<category: 'configuration'>
	^self class baseDirectory
    ]

    baseUrl [
	<category: 'configuration'>
	^self class baseUrl
    ]

    contents [
	<category: 'accessing'>
	| stream |
	^(self directory exists and: [self directory fileExists: self filename]) 
	    ifFalse: [ByteArray new]
	    ifTrue: 
		[stream := self readStream.
		[stream contents] ensure: [stream close]]
    ]

    contents: aByteArray [
	<category: 'accessing'>
	| stream |
	stream := self writeStream.
	[stream nextPutAll: aByteArray asByteArray] ensure: [stream close].
	super contents: aByteArray
    ]

    directory [
	<category: 'accessing-dynamic'>
	^self location inject: self baseDirectory
	    into: [:result :each | result directoryNamed: each]
    ]

    finalize [
	<category: 'initialization'>
	| directory |
	directory := self directory.
	directory exists ifTrue: [directory recursiveDelete].
	[(directory := directory containingDirectory) entries isEmpty] 
	    whileTrue: [directory recursiveDelete].
	super finalize.
	location := nil
    ]

    hash [
	<category: 'comparing'>
	^super hash bitXor: self location hash
    ]

    location [
	<category: 'accessing-dynamic'>
	^location 
	    ifNil: [location := self uniqueLocation: self locationDefinition]
    ]

    locationDefinition [
	<category: 'configuration'>
	^self class locationDefinition
    ]

    postCopy [
	<category: 'copying'>
	| previous |
	super postCopy.
	previous := self contents.
	location := nil.
	self contents: previous
    ]

    readStream [
	<category: 'accessing-dynamic'>
	^(self directory readOnlyFileNamed: self filename) binary
    ]

    uniqueLocation: aLocationDefinition [
	"Finds an unique path to be used and create the necessary sub directories."

	<category: 'private'>
	| valid result directory definition |
	valid := false.
	result := Array new: aLocationDefinition size.
	[valid] whileFalse: 
		[directory := self baseDirectory assureExistence.
		result keysAndValuesDo: 
			[:index :value | 
			definition := aLocationDefinition at: index.
			result at: index
			    put: ((String new: definition first) 
				    collect: [:each | definition second atRandom]).
			directory := directory directoryNamed: (result at: index).
			directory exists 
			    ifFalse: 
				[directory assureExistence.
				valid := true]]].
	^result
    ]

    writeStream [
	<category: 'accessing-dynamic'>
	^(self directory forceNewFileNamed: self filename) binary
    ]
]



MAProxyObject extend [

    isMorph [
	"Answer ==false==, since I am no morph. Squeak is calling this method after image-startup and might lock if I do not answer to this message."

	<category: '*magritte-pharo-model'>
	^false
    ]

]



Grease.GRGSTPlatform extend [

    magritteAllSubInstancesOf: aClass do: aBlock [
	"Evaluate the aBlock for all instances of aClass and all its subclasses."

	<category: '*magritte-pharo-model'>
	aClass allSubInstancesDo: aBlock
    ]

    magritteClassNamed: aString [
	"Return the class named aString, nil if the class can't be found."

	<category: '*magritte-pharo-model'>
	^Smalltalk classNamed: aString
    ]

    magritteColorClass [
	"Return a Color class"

	<category: '*magritte-pharo-model'>
	^Color
    ]

    magritteEvaluate: aBlock onUnhandledErrorDo: errorBlock [
	"Evaluate aBlock. If an Error is signaled and is not handled higher up the
	 stack, evaluate errorBlock with the Error instead of opening a debugger."

	"Apparently allowing #on:do: to be inlined by the compiler is faster than
	 passing errorBlock directly in as a parameter."

	<category: '*magritte-pharo-model'>
	^aBlock on: UnhandledError do: [:error | errorBlock value: error]
    ]

    magritteEvaluatorClassFor: aClass [
	"Answer an evaluator class appropriate for evaluating expressions in the
	 context of this class."

	<category: '*magritte-pharo-model'>
	^aClass evaluatorClass
    ]

    magritteRegister: anObject forMethodChangeNotificationsUsing: selector [
	"Register anObject with the system to be notified whenever a method is
	 added, removed, or modified. When this happens, the specified selector
	 should be called on anObject."

	<category: '*magritte-pharo-model'>
	(Magritte2.SystemChangeNotifier uniqueInstance)
	    notify: anObject
		ofSystemChangesOfItem: #method
		change: #Added
		using: selector;
	    notify: anObject
		ofSystemChangesOfItem: #method
		change: #Modified
		using: selector;
	    notify: anObject
		ofSystemChangesOfItem: #method
		change: #Removed
		using: selector
    ]

    magritteTimeStampClass [
	"Return the platform's TimeStamp class. It is currently assumed that all platforms
	 have one, though this may not be correct and could require moving timestamp stuff
	 to its own package in order to resolve."

	<category: '*magritte-pharo-model'>
	^TimeStamp
    ]

    magritteTimeStampIfAbsent: absentBlock [
	"Return the TimeStamp class, or if the platform does not have a TimeStamp
	 return the result of evaluating absentBlock."

	<category: '*magritte-pharo-model'>
	^TimeStamp
    ]

    magritteUniqueObject [
	"Answer a random object, such as a UUID, that is extremely likely to
	 be unique over space and time."

	<category: '*magritte-pharo-model'>
	^ByteArray withAll: UUID new
    ]

    magritteUnregister: anObject forMethodChangeNotificationsUsing: selector [
	"Unregister anObject with the system for notification whenever a method is
	 added, removed, or modified. anObject should no longer receive notifications
	 using the specified selector."

	<category: '*magritte-pharo-model'>
	Magritte2.SystemChangeNotifier uniqueInstance noMoreNotificationsFor: anObject
    ]

]



Eval [
    MAExternalFileModel initialize
]


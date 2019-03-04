# Use desktop cursor
document.body.style.cursor = "auto"

#Resize UI drawn within Framer's design tool
mainFrame.width = Screen.width
mainFrame.height = Screen.height

#Make UI flex when window resized
Canvas.onResize ->
	mainFrame.width = Screen.width
	mainFrame.height = Screen.height

#General setup
outputText.text = ""
modelsUnder.opacity = 1
footerModels.visible = true
dataUnder.opacity = 0
dataTxt.color = "#1456A1"
modelsTxt.color = "#0579FF"

#Put all the images we want to use w/ Runway in a single array (imported via Framer's design tool)
deadPics = [schoolDrag, jellyDrag, dolphinDrag, clownDrag, kelpDrag, alienDrag, seahorseDrag, reefDrag]	

#CREATE CANVAS FOR BASE64 ENCODING

layer = new Layer
	width: 500
	height: 500
	backgroundColor: null

img2 = new Image
img2.src = dolphin.image

myCanvas = document.createElement("canvas")
myCanvas.width = img2.width*0.5
myCanvas.height = img2.height*0.5

layer._element.appendChild(myCanvas)

myCanvasContext = myCanvas.getContext("2d")

myCanvasContext.drawImage(img2, 0, 0, myCanvas.width, myCanvas.height)
myCanvasContext.scale(1,1)

layer.sendToBack()

#CHAINING FUNCTIONS

#Function for sending caption to AttnGAN model in Runway
sendCaption = (sendString) ->
	animateGradient2(AttnGANBG)
	inputs = 
		'caption': sendString
	fetch 'http://localhost:8001/query',
		method: 'POST'
		headers:
			Accept: 'application/json'
			'Content-Type': 'application/json'
		body: JSON.stringify(inputs)
	.then (response) ->
# 		console.log response.json()
		ganRes = response.json().then (data) ->
# 			console.log data.result
			ganImg = data.result
			outputPic.image = ganImg

#Function for sending image encoded as base64 to im2text model in Runway
sendIt = (base64) ->
	inputs = 
		'image': base64
	fetch 'http://localhost:8000/query',
		method: 'POST'
		headers:
			Accept: 'application/json'
			'Content-Type': 'application/json'
		body: JSON.stringify(inputs)
	.then (response) ->
# 		console.log response.json()
		capRes = response.json().then (data) ->
			console.log data.results[0].caption
			imgLabel = data.results[0].caption
			outputText.text = imgLabel
			sendCaption(imgLabel)

#FUNCTION TO SEND SELECTED IMAGE TO RUNWAY

#Function that encodes selected image as base64 and kicks off chaining of model outputs and inputs
sendImage = (img) ->
	myCanvasContext.clearRect(0, 0, myCanvas.width, myCanvas.height)
	Utils.delay 0.2, ->
		img2.src = img.image
		Utils.delay 0.2, ->
			myCanvasContext.drawImage(img2, 0, 0, myCanvas.width, myCanvas.height)
			imageData = myCanvas.toDataURL("image/jpeg")
	# 		console.log imageData
			sendIt(imageData)
			animateGradient(im2txtBG)

#Switching between footer tabs
modelsTab.onClick ->
	if modelsUnder.opacity == 0
		modelsTxt.color = "#0579FF"
		modelsUnder.opacity = 1
		dataTxt.color = "#1456A1"
		dataUnder.opacity = 0
		footerModels.visible = true

dataTab.onClick ->
	if dataUnder.opacity == 0
		dataTxt.color = "#0579FF"
		dataUnder.opacity = 1
		modelsTxt.color = "#1456A1"
		modelsUnder.opacity = 0
		footerModels.visible = false

#Make im2text model UI draggable	
model1.draggable.enabled = true

model1.draggable.momentumOptions =
	friction: 10
	tolerance: 10

#Hide model UI on load	
# model1.scale = 0.75
# model1.opacity = 0
# 
# model2.scale = 0.75
# model2.opacity = 0

#Animation for the im2text processing state
animateGradient = (layer) ->

	animationA = new Animation layer,
		gradient:
			start: "#0AF"
			end: "#05F"
			angle: 180
		options:
			time: 1.5
			
	animationB = new Animation layer,
		gradient:
			start: "#8C2CA5"
			end: "#E99FF2"
			angle: 38
		options:
			curve: Bezier.easeInOut
			time: 0.75
			
	animationA.start()
	layer.onAnimationEnd ->
		animationB.start()

#Animation for the AttnGAN processing state
animateGradient2 = (layer) ->

	animationA = new Animation layer,
		gradient:
			start: "#0AF"
			end: "#05F"
			angle: 180
		options:
			time: 2.75
			
	animationB = new Animation layer,
		gradient:
			start: "#FFC3DF"
			end: "#FF4C74"
			angle: 320
		options:
			time: 2.75
			
	animationC = new Animation layer,
		gradient:
			start: "#FF3B15"
			end: "#FFB272"
			angle: 38
		options:
			curve: Bezier.easeInOut
			time: 0.75
			
	animationA.start()
	Utils.delay 2.1, ->
		animationB.start()
	Utils.delay 4.2, ->
		animationC.start()

#A function to make all images in Data Tab of footer draggable
dragFunction = (pic) ->
	startX = pic.x
	startY = pic.y
	pic.onDragStart ->
		pic.opacity = 0.5
		
	pic.onDragMove ->
		document.body.style.cursor = "copy"
	
#When release dragged image, it populates im2text Image input UI and sends that image to Runway
	pic.onDragEnd ->
		document.body.style.cursor = "default"
		pic.opacity = 0
		pic.x = startX
		pic.y = startY
		sendImage(pic)
		mainPic.image = pic.image
		


#Call the above draggable function on all our footer images on load so they're draggable
for i, layer in deadPics
	i.draggable.enabled = true
	dragFunction(i)





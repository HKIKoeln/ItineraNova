
function eventWindowLoaded() {
	
	canvasApp();
}

function canvasSupport() {
	
	return 1;
}

function canvasApp() {
	
	var image = new Image();
	image.src = "http://itineranova.be/images/SAL7302/SAL7302_0001.jpg";
	
	if(!canvasSupport()) {
		return;
	}else {
		var canvas = document.getElementById("canvas");
		var context = canvas.getContext("2d");
	}
	
	// canvas
	canvas.width = window.innerWidth * 0.98;
    canvas.height = window.innerHeight * 0.38;
	var canvasWidth = canvas.width;
	var canvasHeight = canvas.height;
	
	// image
	var imageWidth = image.width;
	var imageHeight = image.height;
	var imageRelativeHeight = image.height / image.width;
	
	// logical window
	var windowWidth = canvasWidth;
	var windowHeight = canvasHeight;
	
	// image compared to window
	var img2window = imageWidth / windowWidth;
	
	// offsets
	var windowX = 0;
	var windowY = 0;
	var currentScale = .5;
	var minScale = .2;
	var maxScale = 3;
	var scaleIncrement = .1;
	var scale = 1;
	var originx = 0;
	var originy = 0;
	
	// draw screen when image is loaded
	image.addEventListener("load", eventPhotoLoaded, false);
	
	function eventPhotoLoaded() {
		
		startUp();
	}

	function drawScreen() {
		
		context.fillStyle = "#ffffff";
		context.fillRect(0, 0, canvasWidth, canvasHeight);
		context.drawImage(
			image,
			0,
			200,
			imageWidth,
			canvasHeight * img2window,
			windowX,
			windowY,
			canvasWidth,
			canvasHeight
		);
		
	}
	
	function startUp() {
		
		setInterval(drawScreen, 10);
	}
	
	canvas.onmousewheel = function (event){
		
	    var mousex = event.clientX - canvas.offsetLeft;
	    var mousey = event.clientY - canvas.offsetTop;
	    var wheel = event.wheelDelta/120;//n or -n
	
	    var zoom = 1 + wheel/2;
	
	    context.translate(
	        originx,
	        originy
	    );
	    context.scale(zoom,zoom);
	    context.translate(
	        -( mousex / scale + originx - mousex / ( scale * zoom ) ),
	        -( mousey / scale + originy - mousey / ( scale * zoom ) )
	    );
	
	    originx = ( mousex / scale + originx - mousex / ( scale * zoom ) );
	    originy = ( mousey / scale + originy - mousey / ( scale * zoom ) );
	    scale *= zoom;
	}
}

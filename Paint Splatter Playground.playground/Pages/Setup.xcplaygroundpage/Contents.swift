/*:
 
 # Lets Get Set-up!
 We will be using Metal for our graphics however this is not a tutorial about Metal. As such I have wrapped Metal into a **metalState** class that you will interact with.
 
 Creating a metal state should always be the first thing you do because many other things such as texture creation rely on having Metal set up
 
 Right now we are doing the bare-bones to render to a texture. In metal we call the texture that you render to the drawable. Notice how we are creating one and passing it into the metal state before preparing the frame.
 
 The black texture is quite boring. Lets try to make it more interesting by giving it a color. Try setting the background color by calling `setBackground` on your metal state the move on to the [next page](@next)
 
  These are all things you should do outside of the `prepareFrame()` and `finishFrame() methods`
 */
//Create the metal state
let state = metalState()

//Create a texture and set it as the drawable
let drawOn = TextureTools.createTexture(ofSize: 200)
state.setDrawable(to: drawOn)

//Prepare and finish the frame
state.prepareFrame()
state.finishFrame()

//To see your results
drawOn.displayInPlayground()


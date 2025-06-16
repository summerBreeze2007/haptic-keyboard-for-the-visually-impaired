### What have we created?
We've created two haptic-guided-keyboards for the visually impaired. It is a prototype, not available to be deployed on the default ios keyboard interface. 

The korean keyboard is for those who are able to visually distinguish between different keys if they try, but still suffer discomfort while doing so. For example the elderly who have presbyopia. The size of the keys were slightly increased, and 3 different haptic resonses were used so that no neighboring key would have the same haptic response. This allows the user to identify typos with their finger tips, not needing for them to use their eyes to check which can be difficult. We anticipate it will increase their comfort and speed while typing.  

The english keyboard is for those who cannot visually distinguish between different keys. We designed a bigger keyboard with customized layout and one that has a one-to-one mapping between each key to a unique haptic pattern. The keyboard inserts characters upon releasing your fingertip. The haptic pattern is played when pressed, notifying the user which key their fingertip is at. If they have pressed a wrong key, they can drag their finger to search for the correct key, and release their finger when they've felt the correct haptic response. The keys were colored to further aid the user.

### Who are we and why did we create this?
We are a group of undergraduate students studying computer science and engineering. This is for a project for our HCI (Human-Computer Interaction) course. We had to create an interactive system that benefits the society.

Below, I will guide you through the installments.

### System Requirements
- Xcode installed on your macbook with an apple developer account. The developer account can be created free with an apple account. If you need help with setting up your account, [click here](https://developer.apple.com/register/)
- iOS 17.6 or later installed on your iphone.

### Setup & Running Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/summerBreeze2007/haptic-keyboard-for-the-visually-impaired.git
   ```
   
2. **Open the project**
   ```bash 
   open Group4.xcodeproj
   ```
   or just double-click on the Group4.xcodeproj file.
   
3. **Set your iphone as the target device**
   Use a physical cable to connect your iphone to your macbook.
   On the top bar, click on the current selected device to toggle down to choose your personal device. If you can't find your device, go to "Product" -> "Destination" -> "Manage Run Destination..." and setup.
   
4. **Configure Signing & Capabilities**
   On the left sidebar, you will see directory structure of the project. Click on the root directory (should be "Group4" with the app store icon) to open up the project editor. Look for the "Sigining & Capabilities" tab, and configure your developer account. 

5. **Final steps**
   The default scheme should be selected as the main app scheme: the Group4 scheme. If not, toggle down at the top bar and select the Group4 scheme. 
   Now, try running the code by clicking on the "play button" on top or by using "Cmd + R".
   A message will pop up on your iphone to trust/add your apple developer account under the "일반" -> "VPN 및 기기 관리" settings. After trusting/adding it, re-run the code and you will be able to use our keyboard! Enjoy. (There may be other messages popping on your iphone. If so, follow the instructions)

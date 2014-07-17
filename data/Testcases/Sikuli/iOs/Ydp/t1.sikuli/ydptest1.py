find("1405109220693.png")
if exists("Login.png"):
    find("NotilyYDP.png")
    click("NotifyYDP.png")
    wait(1)
    exists("1405109340882.png")
    find("YDPLogin.png")
    click("AYDPLogin.png")
    wait(1)
    exists("Username.png")
    type("Username-1.png","User1")
    wait(1)
    type("Password.png","password")
    wait(1)
    find("Login-1.png")
    click("Login-2.png")
else:
    print("Not Found")
    
    
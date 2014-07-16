find("1404944860697.png")
click("1404944924027.png")
find("ResolvingSpe.png")
click("ResolvingSpe-1.png")
exists("QuickReferen.png")
find("1404945148613.png")
click("1405019855357.png")
wait(1)
if exists("BannedListsb.png"):
    click("BannedListsb-1.png")
    wait(1)
    find("Vintage.png")
    click("Vintage-1.png")
    exists("1405019981954.png")
    find("1405019992865.png")
    click("1405020002824.png")
    exists("1405020019697.png")
    find("1405020031526.png")
    click("1405020041652.png")
    wait(1)
else:
    print("Not found")
    
    







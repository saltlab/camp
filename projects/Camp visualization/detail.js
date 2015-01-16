    $(function(){ // on dom ready

      console.log(getParameterByName('data'));
      var requiredState=getParameterByName('data');


    ////////*****/////////Iphone states+edges///////////**************/
    //open XML and read States and Edges for iPhone
    if (window.XMLHttpRequest)
      {// code for IE7+, Firefox, Chrome, Opera, Safari
        xmlhttp=new XMLHttpRequest();
      }
      else
      {// code for IE6, IE5
        xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
      }
      xmlhttp.open("GET","xml/iPhoneMapped.xml",false);
      xmlhttp.send();
      xmlDoc=xmlhttp.responseXML;
      var statesIphone=xmlDoc.getElementsByTagName("State");
      var edgesIphone=xmlDoc.getElementsByTagName("Edge");
      for (var i = 0; i < statesIphone.length; i++) {
        if(statesIphone[i].childNodes[13].innerHTML==requiredState){
          console.log("found matching state(IPHONE)")
          var data=statesIphone[i].childNodes[19].innerHTML;
          var stateClassname=statesIphone[i].children[2].innerHTML;
          var stateNumberOfElements=statesIphone[i].children[5].innerHTML;

          //UI element info
          var divUI=document.createElement("div");
          divUI.style.fontSize="medium";
          var UIElements = document.createElement("b");
          UIElements.innerHTML = "UI Elements:";
          UIElements.style.fontSize="xx-large";
          divUI.appendChild(UIElements);
          divUI.appendChild(document.createElement("br"));
          var UIElementsSyntax = document.createElement("b");
          UIElementsSyntax.innerHTML="(Type, Label, Action, Details)";
           UIElementsSyntax.style.fontSize="large";
          divUI.appendChild(UIElementsSyntax);

          var UIElementsArray=statesIphone[i].children[9].children;
          for (var j = 0; j < UIElementsArray.length; j++) {
              divUI.appendChild(document.createElement("br"));
            divUI.appendChild(document.createTextNode("("+UIElementsArray[j].children[2].innerHTML+","
                                                         +UIElementsArray[j].children[3].innerHTML+","
                                                         +UIElementsArray[j].children[4].innerHTML+","
                                                         +UIElementsArray[j].children[5].innerHTML+","+ ")"));
          
          };

          //Sstate info

          var br = document.createElement("br");
          var br2 = document.createElement("br");
          var divElement2=document.createElement("div");

          var stateInfo = document.createElement("b");
          stateInfo.innerHTML = "State Information:";
           stateInfo.style.fontSize="xx-large";
           divElement2.style.fontSize="medium";
          divElement2.appendChild(stateInfo)
          divElement2.appendChild(br);
          divElement2.appendChild(document.createTextNode("Classname: "));
          divElement2.appendChild(document.createTextNode(stateClassname));
          divElement2.appendChild(br2);
          divElement2.appendChild(document.createTextNode("Number of UI elements: "));
          divElement2.appendChild(document.createTextNode(stateNumberOfElements));


          var total="State Information:  "+stateClassname+","+stateNumberOfElements;
          var img = document.createElement("img");
          img.src='images/iphone/Screenshots/Screenshots-iPhone-MTG2/'+statesIphone[i].childNodes[9].innerHTML;
        }
      };



      $(function () {
        var pstyle = 'background-color: #EDF1FA; border: 1px solid #dfdfdf; padding: 5px;';
        $('#cy').w2layout({
          name: 'iphoneLayout',
          panels: [
          
          { type: 'left', size: 320, style: pstyle, content: img},
          { type: 'main', style: pstyle, content: divUI },
          { type: 'preview', style: pstyle, content: divElement2 }

          ]
        });
      });


    ////////*****/////////ANDROID states+edges///////////**************/
    //open XML and read States and Edges for Android
    if (window.XMLHttpRequest)
      {// code for IE7+, Firefox, Chrome, Opera, Safari
        xmlhttp=new XMLHttpRequest();
      }
      else
      {// code for IE6, IE5
        xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
      }
      xmlhttp.open("GET","xml/AndroidMapped.xml",false);
      xmlhttp.send();
      xmlDoc=xmlhttp.responseXML;
      var statesAndroid=xmlDoc.getElementsByTagName("State");
      var edgesAndroid=xmlDoc.getElementsByTagName("Edge");
      console.log(statesAndroid);
      console.log(edgesAndroid);

      for (var i = 0; i < statesAndroid.length; i++) {
        if(statesAndroid[i].childNodes[13].innerHTML==requiredState){
          console.log("found matching state(ANDROID)")
          //APPEND THE ELEMRNT TO CY2

          var dataAndroid=statesAndroid[i].childNodes[19].innerHTML;
          var stateClassnameAndroid=statesAndroid[i].children[2].innerHTML;
          var stateNumberOfElementsAndroid=statesAndroid[i].children[5].innerHTML;
          //UI element info
          var divUIAndroid=document.createElement("div");
          divUIAndroid.style.fontSize="medium";
          var UIElements = document.createElement("b");
          UIElements.innerHTML = "UI Elements:";
          UIElements.style.fontSize="xx-large";
          divUIAndroid.appendChild(UIElements);
          divUIAndroid.appendChild(document.createElement("br"));
          var UIElementsSyntax = document.createElement("b");
          UIElementsSyntax.innerHTML="(Type, Label, Action, Details)";
          UIElementsSyntax.style.fontSize='large';
          divUIAndroid.appendChild(UIElementsSyntax);

          var UIElementsArray=statesAndroid[i].children[9].children;
          for (var j = 0; j < UIElementsArray.length; j++) {
              divUIAndroid.appendChild(document.createElement("br"));
            divUIAndroid.appendChild(document.createTextNode("("+UIElementsArray[j].children[2].innerHTML+","
                                                         +UIElementsArray[j].children[3].innerHTML+","
                                                         +UIElementsArray[j].children[4].innerHTML+","
                                                         +UIElementsArray[j].children[5].innerHTML+","+ ")"));
          
          };


          //states info
          var br = document.createElement("br");
          var br2 = document.createElement("br");
          var divElement=document.createElement("div");
          divElement.style.fontSize="medium";
          var stateInfo = document.createElement("b");
          stateInfo.innerHTML = "State Information:";
          stateInfo.style.fontSize="xx-large";
          divElement.appendChild(stateInfo)
          divElement.appendChild(br);
          divElement.appendChild(document.createTextNode("Classname: "));
          divElement.appendChild(document.createTextNode(stateClassnameAndroid));
          divElement.appendChild(br2);
          divElement.appendChild(document.createTextNode("Number of UI elements: "));
          divElement.appendChild(document.createTextNode(stateNumberOfElementsAndroid));

          var imgAndroid = document.createElement("img");
          imgAndroid.src='images/android/backup/'+statesAndroid[i].childNodes[9].innerHTML;
        }
      };

      $(function () {
        var pstyle = 'background-color: #edfaf6; border: 1px solid #dfdfdf; padding: 5px;';
        $('#cy2').w2layout({
          name: 'AndroidLayout',
          panels: [
          
          { type: 'left', size: 320, style: pstyle, content: imgAndroid},
          { type: 'main', style: pstyle, content: divUIAndroid },
          { type: 'preview', style: pstyle, content: divElement }

          ]
        });
      });



    }); // on dom ready


    function getParameterByName(name) {
      name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
      var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
      results = regex.exec(location.search);
      return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
    }
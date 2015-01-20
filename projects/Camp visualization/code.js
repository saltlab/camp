$(function(){ // on dom ready


////////*****/////////Iphone Graph///////////**************/
var cy = cytoscape({
  container: document.getElementById('cy'),
  style: cytoscape.stylesheet()
    .selector('node')
      .css({
        'background-color': '#6272A3',
        'shape': 'rectangle',
        'height': 180,
        'width': 120,
        'content': 'data(name)'
      })
    .selector('edge')
      .css({
        'line-color': '#00308f',
        'target-arrow-color': '#00308f',
        'width': 5,
        'target-arrow-shape': 'triangle',
        'opacity': 1,
        'content': 'data(name)'
      })
    .selector(':selected')
      .css({
        'background-color': 'black',
        'line-color': 'black',
        'target-arrow-color': 'black',
        'source-arrow-color': 'black',
        'opacity': 1
      })
    .selector('.faded')
      .css({
        'opacity': 0.25,
        'text-opacity': 0
      }),
  
  //elements: elesJson,
  
  layout: {
    name: 'circle',
    padding: 10
  },
  
  ready: function(){
    // ready 1
  }
});

////////*****/////////Android Graph///////////**************/
var cy2 = cytoscape({
  container: document.getElementById('cy2'),
  style: cytoscape.stylesheet()
    .selector('node')
      .css({
        'background-color': '#005502',
        'shape': 'rectangle',
        'height': 180,
        'width': 120,
        'content': 'data(name)'
      })
    .selector('edge')
      .css({
        'width': 'mapData(weight, 0, 10, 3, 9)',
        'line-color': '#3A5F0B',
        'target-arrow-color': '#3A5F0B',
        'target-arrow-shape': 'triangle',
        'opacity': 1,
        'width': 5,
        'content': 'data(name)'
      })
    .selector(':selected')
      .css({
        'background-color': 'black',
        'line-color': 'black',
        'target-arrow-color': 'black',
        'source-arrow-color': 'black',
        'opacity': 1
      }),
  
  //elements: elesJson,
  
  layout: {
    name: 'circle',
    directed: true,
    padding: 10
  },
  
  ready: function(){
    // ready 2
  }
});
 

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
  console.log(statesIphone);
  console.log(edgesIphone);

//Add state 0
cy.add({
    group: "nodes",
    data: { weight: 5, id:'S0'   },
    position: { x: 200, y: 200 },
    css: {'width':'30px', 'height':'30px','shape':'ellipse','background-color':'#00308f'}
});

//Add states or nodes
for (var i = 0; i < statesIphone.length; i++) {
  //console.log(statesIphone[i].childNodes[13].innerHTML);
  var color;
  if(statesIphone[i].childNodes[13].innerHTML==""){
    console.log("HELLOO");
    color='#FE2E2E';
  }
  else if(statesIphone[i].childNodes[13].innerHTML!="" && statesIphone[i].childNodes[17].innerHTML==""){
    color='#A9F5E1';
  }
  else{
    color='#F4FA58';
  }
  cy.add({
    group: "nodes",
    data: {weight: 75, id:statesIphone[i].childNodes[3].innerHTML, name:statesIphone[i].childNodes[13].innerHTML },
    position: { x: 200, y: 200 },
    css: { 'background-image':'images/iphone/'+statesIphone[i].childNodes[9].innerHTML, 'border-color':color,
    'border-width':'5px'


      }
}); 
};

//Add edges 
for (var i = 0; i < edgesIphone.length; i++) {
  console.log(edgesIphone[i].childNodes[13].innerHTML)
  cy.add({
    group: "edges",
    data: { source: edgesIphone[i].childNodes[3].innerHTML, target: edgesIphone[i].childNodes[5].innerHTML,name:edgesIphone[i].childNodes[13].innerHTML},
    position: { x: 200, y: 200 }
}); 
};

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

//Add state 0
cy2.add({
    group: "nodes",
    data: { weight: 75, id:'S0'},
    position: { x: 200, y: 200 },
    css: {'width':'30px', 'height':'30px','shape':'ellipse','background-color':'#005502'}
});

//Add states or nodes
for (var i = 0; i < statesAndroid.length; i++) {
  //console.log(statesAndroid[i].childNodes[13].innerHTML);
  var color;
  if(statesAndroid[i].childNodes[13].innerHTML==""){
    console.log("HELLOO");
    color='#FE2E2E';
  }
  else if(statesAndroid[i].childNodes[13].innerHTML!="" && statesAndroid[i].childNodes[17].innerHTML==""){
    color='#A9F5E1';
  }
  else{
    color='#F4FA58';
  }
  cy2.add({
    group: "nodes",
    data: {weight: 75, id:statesAndroid[i].childNodes[3].innerHTML, name:statesAndroid[i].childNodes[13].innerHTML },
    position: { x: 200, y: 200 },
    css: { 'background-image':'images/android/'+statesAndroid[i].childNodes[9].innerHTML, 'border-color':color,
    'border-width':'5px'  }
}); 
};

//Add edges 
for (var i = 0; i < edgesAndroid.length; i++) {
  console.log(edgesAndroid[i].childNodes[13].innerHTML)
  cy2.add({
    group: "edges",
    data: { source: edgesAndroid[i].childNodes[3].innerHTML, target: edgesAndroid[i].childNodes[5].innerHTML,name:edgesAndroid[i].childNodes[13].innerHTML},
    position: { x: 200, y: 200 }
}); 
};


var control=false;
////////////////////////////Iphone ONCLICKS////////////////////////////
cy.on('tap', function(event){
  // cyTarget holds a reference to the originator
  // of the event (core or element)
  var evtTarget = event.cyTarget;

  if( evtTarget === cy ){
      console.log('tap on background');
      
      cy.zoom({
       level: 0.5 // the zoom level
        //position: { x: 0, y: 0 }
      });
      cy.center();

    if(control==true){
      cy2.zoom({
       level: 0.5 // the zoom level
        //position: { x: 0, y: 0 }
      });
      cy2.center();
    }
  } else {
    var node = event.cyTarget;
   // console.log( 'tapped ' + node.id() );
    var temp=(cy.getElementById(node.id()));
    //console.log(temp.data().name);
    var tempName=temp.data().name;
    console.log(cy2.nodes("[name='"+tempName+"']").length);
    var pos = temp.position();
    //found a matching element
    cy.zoom({
      level: 1,
      position: pos
    });
    if(cy2.nodes("[name='"+tempName+"']").length>0){
     // cy.destroy();
     control=true;
     var matchedNodes=cy2.nodes("[name='"+tempName+"']");
     var pos2=(matchedNodes[0].position());

     cy.zoom({
      level: 1,
      position: pos
      });

      cy2.zoom({
      level: 1,
      position: pos2
      });
       var delay=2500;//1 seconds
       setTimeout(function(){
         window.location.href = "detail.html?data="+tempName;
        //your code to be executed after 1 seconds
        },delay); 
     
    }

  }
});

////////////////////////////ANDROID ONCLICKS////////////////////////////
var control2=false;
var counter2=0;
cy2.on('tap', function(event){
  // cyTarget holds a reference to the originator
  // of the event (core or element)

  
  var evtTarget = event.cyTarget;

  if( evtTarget === cy2 ){
      counter2--;
      console.log('tap on background');
      
      cy2.zoom({
       level: 0.7 // the zoom level
        //position: { x: 0, y: 0 }
      });
      cy2.center();

    if(control2==true){
      cy.zoom({
       level: 0.555 // the zoom level
        //position: { x: 0, y: 0 }
      });
      cy.center();
    }
  } else {
      counter2++;
    var node = event.cyTarget;
   // console.log( 'tapped ' + node.id() );
    var temp=(cy2.getElementById(node.id()));
    //console.log(temp.data().name);
    var tempName=temp.data().name;
    console.log(cy.nodes("[name='"+tempName+"']").length);
    var pos = temp.position();
    //found a matching element
    cy2.zoom({
      level: 1,
      position: pos
    });
    if(cy.nodes("[name='"+tempName+"']").length>0){
     // cy.destroy();
     control2=true;
     var matchedNodes=cy.nodes("[name='"+tempName+"']");
     var pos2=(matchedNodes[0].position());

     cy2.zoom({
      level: 1,
      position: pos
      });

      cy.zoom({
      level: 1,
      position: pos2
      });
      
     
    }

  }

  if(counter2>1){
     var node = event.cyTarget;
   // console.log( 'tapped ' + node.id() );
    var temp=(cy2.getElementById(node.id()));
    //console.log(temp.data().name);
    var tempName=temp.data().name;

    window.location.href = "detail.html?data="+tempName;
  }
});




}); // on dom ready
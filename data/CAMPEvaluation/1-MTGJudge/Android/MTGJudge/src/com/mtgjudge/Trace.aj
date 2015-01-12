package com.mtgjudge;
import java.util.Map;
import java.util.HashMap;
import java.util.Vector;


/**
 * The Trace aspect injects tracing messages before and after method main of
 * class HelloWorld.
 */

aspect Trace {

	 
	 pointcut androidWidget(): 
			execution(* android.app..*(..))&& !within(com.mtgjudge.Trace);
		
		 after() : androidWidget() {
		    	System.out.print("EVENT"+thisJoinPointStaticPart.getSignature().toString()+"\n");
		    	

		    }
	
	
	/*
	pointcut createCalls(): 
		execution(* com.mtgjudge..*.onCreate(..))&& !within(com.mtgjudge.Trace);
	
	 after() : createCalls() {
	    	System.out.print("ONCREATEEEE\n");
	    	

	    }
	*/
	pointcut methodCalls(): 
	  execution(* com.mtgjudge..*(..))&& !within(com.mtgjudge.Trace);

	 
	    

	Object around() : methodCalls() {
		
		String threadName = Thread.currentThread().getName();
		
		if(null==threadMap.get(threadName)){
			threadMap.put(threadName,0);
		}
		
		int stackDepth = threadMap.get(threadName) + 1;
		
		
		
		threadMap.put(threadName,stackDepth);

		
		String name = Thread.currentThread().getName();
		
		String indent = "";
		
		for (int index = 0; index < stackDepth; index++) {
			indent += "   ";
		}

		System.out.println(name+":"+indent + ">>>>    "
				+ thisJoinPointStaticPart.getSignature().toString());
		
		long start = System.currentTimeMillis();
		try {
			return proceed();
		} finally {

			long end = System.currentTimeMillis();
			
			System.out.println(name+":"+indent + "<<<< "
					+ thisJoinPointStaticPart.getSignature().toString() + "("
					+ (end - start) + " milliseconds)");
			
			threadMap.put(threadName,stackDepth - 1);
			System.out.print("THREAD MAP!\n");
			threadMap.toString();
		}

	}

	private static Map<String, Integer> threadMap= new HashMap<String,Integer>();
	private Vector<Node> nodes;
	private Vector<Edge> edges;
	private int edgeIdCounter;
	private int nodeIdCounter;
	

}


// Copyright 2011 The Chicago Independent Radio Project 
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package org.chirpradio.mobile;

import android.app.Activity;
import android.os.Bundle;

import android.content.Intent;
import android.view.View;
import android.view.View.OnClickListener;

// THIS IS NOT USED!!!


public class MainMenu extends Activity implements OnClickListener {
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main_menu);
        
        View playingButton = findViewById(R.id.playing_button);
        playingButton.setOnClickListener(this);       

        Debug.log(this, "blah");
    }
    
    public void onClick(View v) {
    	switch (v.getId()) {
    	case R.id.playing_button:
            String str = Request.sendRequest();
            Debug.log(this, str);
    		//Intent i = new Intent(this, Playing.class);
    		//startActivity(i);
    		break;
    	}
    }
}

/**
 Author:         serhiivolynets
 Date:           31.08.2021
 Description:
 **/
({
    // doInit : function(component, event, helper) {
    //     var action = component.get("c.insertAudit");
    //     action.setParams({"recordId":component.get("v.recordId")});
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         // Display toast message to indicate load status
    //         var toastEvent = $A.get("e.force:showToast");
    //         if (state === 'SUCCESS'){
    //             toastEvent.setParams({
    //                 "title": "Success!",
    //                 "message": " Audit Log is created ."
    //             });
    //         }
    //         else {
    //             toastEvent.setParams({
    //                 "title": "Error!",
    //                 "message": " Something has gone wrong."
    //             });
    //         }
    //         toastEvent.fire();
    //     });
    //     $A.enqueueAction(action);
    // }

    onAgentSend: function (cmp, evt, helper) {
        var recordId = evt.getParam("recordId");
        var content = evt.getParam("content");
        var name = evt.getParam("name");
        var type = evt.getParam("type");
        var timestamp = evt.getParam("timestamp");
        console.log("recordId:" + recordId + " content:" + content + " name:" + name + " timestamp:" + timestamp);
        var action = cmp.get("c.logAgentReply");
        action.setParams({"recordId": recordId, "content": content, "name": name, "type": type});
        action.setCallback(this, function (response) {
            var state = response.getState();
            // Display toast message to indicate load status
            // var toastEvent = $A.get("e.force:showToast");
            if (state === 'SUCCESS') {
                console.log('live chat send success');
                // toastEvent.setParams({
                //     "title": "Success!",
                //     "message": " Audit Log is created ."
                // });
            } else {
                console.log('live chat send error:'+response.getError());
                // toastEvent.setParams({
                //     "title": "Error!",
                //     "message": " Something has gone wrong."
                // });
            }
            // toastEvent.fire();

        });
        $A.enqueueAction(action);
    },
    onChatEnded: function (cmp, evt, helper) {
        var recordId = evt.getParam("recordId");
        console.log("recordId:" + recordId);
        var action = cmp.get("c.chatEnded");
        action.setParams({"recordId": recordId});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('live chat end success');
            } else {
                console.log('live chat end error:'+response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})

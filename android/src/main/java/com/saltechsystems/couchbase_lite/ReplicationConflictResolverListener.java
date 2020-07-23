package com.saltechsystems.couchbase_lite;

import android.os.Handler;
import android.os.Looper;

import com.couchbase.lite.Conflict;
import com.couchbase.lite.ConflictResolver;
import com.couchbase.lite.CouchbaseLiteException;
import com.couchbase.lite.Document;
import com.couchbase.lite.ListenerToken;
import com.couchbase.lite.ReplicatorChange;
import com.couchbase.lite.ReplicatorChangeListener;

import io.flutter.plugin.common.EventChannel;

public class ReplicationConflictResolverListener implements  EventChannel.StreamHandler, ConflictResolver {
//    private CBManager mCBManager;
//    private ListenerToken mListenerToken;
    public  EventChannel.EventSink mEventSink;

    /*public ReplicationEventListener(CBManager manager) {
        mCBManager = manager;
    }*/

    /*
     * IMPLEMENTATION OF EVENTCHANNEL.STREAMHANDLER
     */

//    @Override
    public void onListen(Object o, final EventChannel.EventSink eventSink) {
        mEventSink = eventSink;
//        mListenerToken = mCBManager.getReplicator().addChangeListener(this);
    }

    @Override
    public void onCancel(Object o) {
//        if (mListenerToken != null) {
//            mCBManager.getReplicator().removeChangeListener(mListenerToken);
//        }
//
//        mListenerToken = null;
        mEventSink = null;
    }
    @Override
    public Document resolve(final Conflict conflict) {
//        System.out.println("inside  conlict reolver "+conflict.toString());
        try{

//            System.out.println("print mEventSink=="+mEventSink);
            new Handler(Looper.getMainLooper()).post(new Runnable() {
                @Override
                public void run() {
//                    System.out.println(">>>>>>>.inside  new Handler(Looper.getMainLooper())");
                    mEventSink.success("conflict doc ID : "+conflict.getDocumentId());
                }
            });
//            mEventSink.success("BUSYxeeeee");

        }catch (Exception e){
            System.err.println(">>>>> ERRROR : "+e.getMessage());
            e.printStackTrace();
        }

        return conflict.getLocalDocument();
    }
}

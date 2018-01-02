    //
    //  IITMSCThreadController.swift
    //  IITMCSCallstackSampling
    //
    //  Created by NovaTec on 07.09.17.
    //  Copyright © 2017 NovaTec. All rights reserved.
    //
    
    import UIKit
    
    public var Calling_Thread: pthread_t?
    public var Target_Thread: pthread_t?
    
    public var lowestTime: UInt64 = UINT64_MAX
    public var highestTime: UInt64 = 0
    
    func signalFunction(sig: Int32, siginfo: UnsafeMutablePointer<__siginfo>?, p: UnsafeMutableRawPointer?) {
        let start = getTimestamp()
        
        //if pthread_self() == ViewController.P_THREAD {
        if pthread_self() != Target_Thread {
            return
        }
        
        let symbols: [String] = Thread.callStackSymbols.reversed()
        IITMAgent.getInstance().invocationOrganizer.createSpanStack(symbols: symbols)
        
        siginfo?.deinitialize()
        
        if Calling_Thread != nil {
            //pthread_kill(Calling_Thread!, SIGALRM)
        }
        let duration = getTimestamp() - start
        
        if duration < lowestTime {
            lowestTime = duration
        }
        if duration > highestTime {
            highestTime = duration
        }
        print("highest TIME: \(highestTime)")
        print("lowest TIME: \(lowestTime)")
    }
    
    
    
    
    class IITMThreadController: NSObject {
        
        var threadsWithSignal = [pthread_t : Bool?]()
        
        func fetchThreads() -> [pthread_t] {
            
            var list = [pthread_t]()
            
            let threads: UnsafeMutablePointer<thread_act_array_t?> = UnsafeMutablePointer<thread_act_array_t?>.allocate(capacity: 1)
            let thread_count: UnsafeMutablePointer<mach_msg_type_number_t> = UnsafeMutablePointer<mach_msg_type_number_t>.allocate(capacity: 1)
            let machport: task_t = mach_task_self_
            
            if task_threads(machport, threads, thread_count) != KERN_SUCCESS {
                print("Fetching thread list failed");
                thread_count.pointee = 0
            }
            
            var index : mach_msg_type_number_t = 0
            
            while index < thread_count.pointee {
                let thread: thread_t = (threads.pointee?.advanced(by: Int(index)).pointee)!
                if let pthread: pthread_t = pthread_from_mach_thread_np(thread) {
                    if pthread != Calling_Thread {
                        list.append(pthread)
                    }
                }
                index = index + 1
            }
            threads.deallocate(capacity: 1)
            thread_count.deallocate(capacity: 1)
            return list
        }
        
        func setSignal(pthread: inout pthread_t) {
            //thread_suspend(thread)
            
            // print(pthread)
            
            Target_Thread = pthread
            //thread_suspend(thread)
            
            if threadsWithSignal[pthread] == nil || (threadsWithSignal[pthread]!) == false {
                
                var sinfo = siginfo_t()
                sinfo.si_signo = SIGALRM
                
                var sAction = sigaction()
                sAction.__sigaction_u.__sa_sigaction = signalFunction(sig:siginfo:p:)
                sAction.sa_flags = SA_SIGINFO
                
                let _ = withUnsafeMutablePointer(to: &sAction) {
                    sigaction(SIGALRM, $0, nil)
                }
                
                threadsWithSignal[pthread] = true
            }
            
            if pthread != pthread_self() && pthread_kill(pthread, SIGALRM) == 0 {
                //index = index + 1
                /*
                 var mask = sigset_t()
                 sigfillset(&mask)
                 sigdelset(&mask, SIGALRM)
                 
                 sigsuspend(&mask)
                 */
            }
            //thread_resume(thread)
        }
        
    }

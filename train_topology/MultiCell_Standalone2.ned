// 
//                  Simu5G
//
// Authors: Giovanni Nardini, Giovanni Stea, Antonio Virdis (University of Pisa)
// 
// This file is part of a software released under the license included in file
// "license.pdf". Please read LICENSE and README files before using it.
// The above files and the present reference are part of the software itself, 
// and cannot be removed from it.
// 
package train_topology;

import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
import inet.networklayer.ipv4.RoutingTableRecorder;
import inet.node.ethernet.Eth1G;
import inet.node.inet.Router;
import inet.node.inet.StandardHost;
import inet.node.tsn.*;
import simu5g.common.binder.Binder;
import simu5g.common.carrierAggregation.CarrierAggregation;
import simu5g.nodes.Upf;
import simu5g.nodes.NR.gNodeB;
import simu5g.nodes.NR.NRUe;
import simu5g.nodes.backgroundCell.BackgroundCell;
import simu5g.world.radio.LteChannelControl;
import *;

// MultiCell_standalone
//
// This network represents the deployment option 3 in 3GPP 38.801
//
network MultiCell_Standalone2
{
    parameters:
        int TCUNum = default(4);
        int BCUNum = default(4);
        int numBgCells = default(0);
        @display("i=bgi=background/train;bgb=4315.567,1647.9696");
        **.eth[*].bitrate = default(1Gbps);
        **.ethInterface.bitrate = default(1Gbps);
    submodules:
        channelControl: LteChannelControl {
            @display("p=50,25;is=s");
        }
        routingRecorder: RoutingTableRecorder {
            @display("p=50,75;is=s");
        }
        configurator: Ipv4NetworkConfigurator {
            @display("p=50,125");
        }
        binder: Binder {
            @display("p=50,175;is=s");
        }
        carrierAggregation: CarrierAggregation {
            @display("p=50.993748,258.7;is=s");
        }
        server: TsnDevice {
            @display("p=212,118;is=n;i=device/server");
        }
        switch1: TsnSwitch {
            @display("p=351.81198,115.771996;i=device/smallrouter");
        }
        switch2: TsnSwitch {
            @display("p=1684,182");
        }
        switch3: TsnSwitch {
            @display("p=1375,78");
        }
        upf1: MyUpf2 {
            @display("p=300,115");
        }
        upf2: MyUpf2 {
            @display("p=700,115");
        }
        iUpf1: Upf {
            @display("p=300,215");
        }
        iUpf2: Upf {
            @display("p=700,215");
        }
        gnb1: gNodeB {
            gateway = "iUpf1";
            @display("p=250,300;is=vl");
        }
        gnb2: gNodeB {
            gateway = "iUpf2";
            @display("p=750,300.556;is=vl");
        }
        TCUUe[TCUNum]: TsnUe {
            @display("p=120,400,r,250;");
        }
        BCUUe[BCUNum]: TsnUe {
            @display("p=120,500,r,250;");
        }
        TCUClient[TCUNum]: TsnDevice {
        	@display("p=120,400,r,250;");
        }
        BCUClient[BCUNum]: TsnDevice {
        	@display("p=120,500,r,250;");
        }
    connections:
		for i=0..TCUNum-1 {
            TCUClient[i].ethg++ <--> Eth1G <--> TCUUe[i].phys;
        }
        for i=0..BCUNum-1 {
            BCUClient[i].ethg++ <--> Eth1G <--> BCUUe[i].phys;
        }
        //# Data Network connections
        server.ethg++ <--> Eth1G <--> switch1.ethg++;
        switch1.ethg++ <--> Eth1G <--> upf1.filterGate;
        switch2.ethg++ <--> Eth1G <--> upf2.filterGate;
        
		switch1.ethg++ <--> Eth1G <--> switch3.ethg++;
//        switch1.ethg++ <--> Eth1G <--> switch2.ethg++;
        switch3.ethg++ <--> Eth1G <--> switch2.ethg++;
        
        //# 5G Core Network connections
        upf1.pppg++ <--> Eth1G <--> iUpf1.pppg++;
        upf2.pppg++ <--> Eth1G <--> iUpf2.pppg++;
        iUpf1.pppg++ <--> Eth1G <--> gnb1.ppp;
        iUpf2.pppg++ <--> Eth1G <--> gnb2.ppp;

        //# X2 connections
        gnb1.x2++ <--> Eth1G <--> gnb2.x2++;
}

//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
// 

package train_topology;
import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
import inet.networklayer.ipv4.RoutingTableRecorder;
import simu5g.common.binder.Binder;
import simu5g.world.radio.LteChannelControl;
import simu5g.common.carrierAggregation.CarrierAggregation;
import simu5g.nodes.Upf;
import simu5g.nodes.NR.gNodeB;
import simu5g.nodes.NR.NRUe;
import inet.node.tsn.*;
import inet.node.ethernet.*;
import inet.node.inet.Router;
import inet.node.inet.StandardHost;
import inet.networks.base.TsnNetworkBase;
import *;
network TrainTopology
{
    parameters:
        // kong tiao
        int numHVAC = 4;
        int numFAS = 4;
        int numPIS = 4;
        // qian yin
        int numTCU = 4;
        // zhi dong
        int numBCU = 4;
        **.eth[*].bitrate = default(1Gbps);

        **.ethInterface.bitrate = default(1Gbps);
        **.dstt.bitrate = default(1Gbps);
        @display("bgi=background/train;bgb=4315.567,1647.9696");
    submodules:
        carrierAggregation: CarrierAggregation {
            @display("p=100,27;is=s");
        }
        channelControl: LteChannelControl {
            @display("p=196,27;is=s");
        }
        routingRecorder: RoutingTableRecorder {
            @display("p=176,88;is=s");
        }
        binder: Binder {
            @display("p=176,200;is=s");
        }
        server: TsnDevice {
            @display("p=1893,79");
        }
        switch1: TsnSwitch {
            @display("p=1122,182");
        }
        switch2: TsnSwitch {
            @display("p=1684,182");
        }
        switch3: TsnSwitch {
            @display("p=1375,78");
        }
        upf1: MyUpf2 {
            @display("p=811,336;is=s");
        }
        upf2: MyUpf2 {
            @display("p=2003,346;is=s");
        }
        gnb1: gNodeB {
            gateway = "upf1";
            @display("p=811.19995,485.03");
        }

        gnb2: gNodeB {
            gateway = "upf2";
            @display("p=2011.1,485.03");
        }
        //        HVACClient[numHVAC]: TsnDevice {
        //            
        //            @display("i=device/card;p=350,600,r,600;is=s;");
        //        }
        //        HVACUe[numHVAC]: TsnUe {
        //            @display("i=device/card;p=350,600,r,600;is=s;");
        //        }
        //        FASClient[numFAS]: TsnDevice {
        //            @display("i=device/card;p=350,700,r,600;is=s;");
        //        }
        //        FASUe[numFAS]: TsnUe {
        //            @display("i=device/card;p=350,700,r,600;is=s;");
        //        }
        TCUClient[numTCU]: TsnDevice {
            @display("i=device/card;p=450,400,r,600;is=s;");
        }
        TCUUe[numTCU]: TsnUe {
            @display("i=device/card;p=450,400,r,600;is=s;");
        }
        BCUClient[numBCU]: TsnDevice {
            @display("i=device/device;p=450,500,r,600;is=s;");
        }
        BCUUe[numBCU]: TsnUe {
            @display("i=device/device;p=450,500,r,600;is=s;");
        }
		configurator: Ipv4NetworkConfigurator {
            parameters:
                @display("p=100,300;is=s");
        }
    connections:
        //        for i=0..numHVAC-1 {
        //            HVACClient[i].ethg++ <--> Eth1G <--> HVACUe[i].phys;
        //        }
        //        for i=0..numFAS-1 {
        //            FASClient[i].ethg++ <--> Eth1G <--> FASUe[i].phys;
        //        }
        //
        for i=0..numTCU-1 {
            TCUClient[i].ethg++ <--> Eth1G <--> TCUUe[i].phys;
        }
        for i=0..numBCU-1 {
            BCUClient[i].ethg++ <--> Eth1G <--> BCUUe[i].phys;
        }

        switch1.ethg++ <--> Eth1G <--> switch3.ethg++;
//        switch1.ethg++ <--> Eth1G <--> switch2.ethg++;
        switch3.ethg++ <--> Eth1G <--> switch2.ethg++;
        switch1.ethg++ <--> Eth1G <--> upf1.filterGate;
        switch2.ethg++ <--> Eth1G <--> upf2.filterGate;
        //        nwtt1.phys <--> Eth1G <--> switch1.ethg++;
        //        iupf1.pppg++ <--> Eth1G <--> gnb1.ppp;
        //        iupf2.pppg++ <--> Eth1G <--> gnb2.ppp;
        //# X2 connections
        gnb1.x2++ <--> Eth1G <--> gnb2.x2++;
        gnb1.ppp <--> Eth1G <--> upf1.pppg++;
        gnb2.ppp <--> Eth1G <--> upf2.pppg++;
        switch3.ethg++ <--> Eth1G <--> server.ethg++;

}

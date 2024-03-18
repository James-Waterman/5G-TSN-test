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

//package tsn5g.simulations;
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

network TSN5GPLUS extends TsnNetworkBase
{
    parameters:
        int besteffortPort = 1000;
        int videoPort = 1001;
        *.eth[*].bitrate = default(100Mbps);
        @display("bgb=1747.6351,932.99255");
    submodules:
        carrierAggregation: CarrierAggregation {
            @display("p=1479.2579,399.09598");
        }
        channelControl: LteChannelControl {
            @display("p=1477.812,52.056;is=s");
        }
        routingRecorder: RoutingTableRecorder {
            @display("p=1479.2579,187.98;is=s");
        }
        binder: Binder {
            @display("p=1479.2579,294.98398;is=s");
        }
        tsnServer: TsnDevice {
            @display("p=1132.2999,209.56");
        }
        tsnSwitch: TsnSwitch {
            @display("p=985.26996,334.62");
        }
        upf: MyUpf {
            @display("p=682.76,251.81");
        }
        gnb: gNodeB {
            @display("p=632.06,449.53998;is=vl");
        }
        tsnClient: TsnDevice {
            @display("p=415.74,550.94");
        }
        ue1: TsnUe {
            @display("p=415.74,312.65");
        }

    connections:
        tsnClient.ethg++ <--> Eth100M <--> ue1.phys;
        tsnSwitch.ethg++ <--> Eth100M <--> tsnServer.ethg++;
        upf.filterGate <--> Eth100M <--> tsnSwitch.ethg++;
        upf.pppg++ <--> Eth100M <--> gnb.ppp;
}


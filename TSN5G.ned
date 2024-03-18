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

import inet.node.ethernet.Eth10M;
import inet.node.inet.Router;
import inet.node.inet.StandardHost;
import inet.networks.base.TsnNetworkBase;

network TSN5G extends TsnNetworkBase
{
    parameters:
        *.eth[*].bitrate = default(10Mbps);
        @display("bgb=1747.6351,932.99255");
    submodules:

        tsnServer: TsnDevice {

            @display("p=1081.6,223.08");
        }
        //        tsnClock: TsnClock {
        //
        //            @display("p=733.122,108.45");
        //        }
        tsnSwitch: MyTsnSwitch {
            @display("p=1081.6,496.86");
        }

        tsnClient1: TsnDevice {

            @display("p=451.22998,498.55");
        }
        tsnClient2: TsnDevice {

            @display("p=1105.26,748.67");
        }
    connections:
        tsnSwitch.ethg++ <--> Eth10M <--> tsnServer.ethg++;
        tsnSwitch.ethg++ <--> Eth10M <--> tsnClient1.ethg++;
        tsnSwitch.ethg++ <--> Eth10M <--> tsnClient2.ethg++;
}

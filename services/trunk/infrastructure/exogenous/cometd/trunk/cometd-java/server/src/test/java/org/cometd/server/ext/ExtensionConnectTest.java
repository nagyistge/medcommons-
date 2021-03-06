package org.cometd.server.ext;

import java.util.ArrayList;
import java.util.List;

import org.cometd.Bayeux;
import org.cometd.Client;
import org.cometd.Extension;
import org.cometd.Message;
import org.cometd.server.AbstractBayeuxClientServerTest;
import org.eclipse.jetty.client.ContentExchange;
import org.eclipse.jetty.client.HttpExchange;

/**
 * @version $Revision: 1035 $ $Date: 2010-03-22 06:59:52 -0400 (Mon, 22 Mar 2010) $
 */
public class ExtensionConnectTest extends AbstractBayeuxClientServerTest
{
    private CountingExtension extension;

    @Override
    protected void customizeBayeux(Bayeux bayeux)
    {
        extension = new CountingExtension();
        bayeux.addExtension(extension);
    }

    public void testExtension() throws Exception
    {
        ContentExchange handshake = newBayeuxExchange("[{" +
                                                  "\"channel\": \"/meta/handshake\"," +
                                                  "\"version\": \"1.0\"," +
                                                  "\"minimumVersion\": \"1.0\"," +
                                                  "\"supportedConnectionTypes\": [\"long-polling\"]" +
                                                  "}]");
        httpClient.send(handshake);
        assertEquals(HttpExchange.STATUS_COMPLETED, handshake.waitForDone());
        assertEquals(200, handshake.getResponseStatus());

        String clientId = extractClientId(handshake.getResponseContent());

        ContentExchange connect = newBayeuxExchange("[{" +
                                                 "\"channel\": \"/meta/connect\"," +
                                                 "\"clientId\": \"" + clientId + "\"," +
                                                 "\"connectionType\": \"long-polling\"" +
                                                 "}]");
        httpClient.send(connect);
        assertEquals(HttpExchange.STATUS_COMPLETED, connect.waitForDone());
        assertEquals(200, connect.getResponseStatus());

        assertEquals(0, extension.rcvs.size());
        assertEquals(1, extension.rcvMetas.size());
        assertEquals(0, extension.sends.size());
        assertEquals(1, extension.sendMetas.size());
    }

    private class CountingExtension implements Extension
    {
        private final List<Message> rcvs = new ArrayList<Message>();
        private final List<Message> rcvMetas = new ArrayList<Message>();
        private final List<Message> sends = new ArrayList<Message>();
        private final List<Message> sendMetas = new ArrayList<Message>();

        public Message rcv(Client client, Message message)
        {
            rcvs.add(message);
            return message;
        }

        public Message rcvMeta(Client client, Message message)
        {
            if (Bayeux.META_CONNECT.equals(message.getChannel()))
            {
                rcvMetas.add(message);
            }
            return message;
        }

        public Message send(Client client, Message message)
        {
            sends.add(message);
            return message;
        }

        public Message sendMeta(Client client, Message message)
        {
            if (Bayeux.META_CONNECT.equals(message.getChannel()))
            {
                sendMetas.add(message);
            }
            return message;
        }
    }
}

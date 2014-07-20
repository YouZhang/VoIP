% SERVER Write a message over the specified port
% 
% Usage - server(message, output_port, number_of_retries)
function [get,client_ip] = server(message, output_port, number_of_retries)
    import java.net.getLocalHost.*
    import java.net.ServerSocket
    import java.io.*
%     import java.awt.*;
%     import javax.swing.*;
    
    if (nargin < 3)
        number_of_retries = 20; % set to -1 for infinite
    end
    retry             = 0;
    get = 0;
    server_socket  = [];
    output_socket  = [];

    while true

        retry = retry + 1;

        try
            if ((number_of_retries > 0) && (retry > number_of_retries))
                fprintf(1, 'Too many retries\n');
                break;
            end
%             addr = getLocalHost();
            fprintf(1, ['Try %d waiting for client to connect to this ' ...
                        'host on port : %d\n'], retry, output_port);

            % wait for 1 second for client to connect server socket
            server_socket = ServerSocket(output_port);
            server_socket.setSoTimeout(1000);

            output_socket = server_socket.accept;
            get = 1;
            fprintf(1, 'Client connected\n');
            client_ip = char(output_socket.getInetAddress.getHostAddress);
%             client_port = output_socket.getLocalPort;
            output_stream   = output_socket.getOutputStream;
            d_output_stream = DataOutputStream(output_stream);
%             d_input_stream = DataInputStream(input_stream);
            % output the data over the DataOutputStream
            % Convert to stream of bytes
            fprintf(1, 'Writing %d bytes\n', length(message))
            d_output_stream.writeBytes(char(message));
            d_output_stream.flush;
            
            % clean up
            server_socket.close;
            output_socket.close;
            break;
            
        catch
            if ~isempty(server_socket)
                server_socket.close
            end

            if ~isempty(output_socket)
                output_socket.close
            end

            % pause before retrying
            pause(1);
        end
    end
end
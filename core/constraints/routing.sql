-- Routing Schema Foreign Key Constraints

-- callback_routes -> providers
ALTER TABLE routing.callback_routes
    ADD CONSTRAINT fk_callback_routes_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- callback_routes -> clients
ALTER TABLE routing.callback_routes
    ADD CONSTRAINT fk_callback_routes_client
    FOREIGN KEY (client_id) REFERENCES core.clients(id);

-- provider_callbacks -> providers
ALTER TABLE routing.provider_callbacks
    ADD CONSTRAINT fk_provider_callbacks_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

-- provider_endpoints -> providers
ALTER TABLE routing.provider_endpoints
    ADD CONSTRAINT fk_provider_endpoints_provider
    FOREIGN KEY (provider_id) REFERENCES catalog.providers(id);

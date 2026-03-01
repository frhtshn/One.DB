-- Routing Schema Indexes
-- FK indexes for optimal JOIN performance

-- callback_routes.provider_id -> providers.id
CREATE INDEX idx_callback_routes_provider_id ON routing.callback_routes USING btree(provider_id);

-- callback_routes.client_id -> clients.id
CREATE INDEX idx_callback_routes_client_id ON routing.callback_routes USING btree(client_id);

-- callback_routes (unique lookup by route_key)
CREATE INDEX idx_callback_routes_route_key ON routing.callback_routes USING btree(route_key);

-- provider_callbacks.provider_id -> providers.id
CREATE INDEX idx_provider_callbacks_provider_id ON routing.provider_callbacks USING btree(provider_id);

-- provider_endpoints.provider_id -> providers.id
CREATE INDEX idx_provider_endpoints_provider_id ON routing.provider_endpoints USING btree(provider_id);

-- provider_endpoints (lookup by gateway)
CREATE INDEX idx_provider_endpoints_gateway ON routing.provider_endpoints USING btree(gateway_code);

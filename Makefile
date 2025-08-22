# Curly v0.2 Makefile
# Easy setup and management for the Curly API testing tool

.PHONY: help bootstrap clean 

# Default target
help:
	@echo "Curly v0.2 - API Testing Tool"
	@echo "=============================="
	@echo ""
	@echo "Available targets:"
	@echo "  help     - Show this help message"
	@echo "  bootstrap    - Set up Curly environment and permissions"
	@echo "  clean    - Clean up temporary files and audit directories"
	@echo ""

# Set up Curly environment and permissions
bootstrap:
	@echo "Installing Curly dependencies..."
	brew bundle install
	@echo "Dependencies installed successfully!"
	@echo "Setting up Curly environment..."
	@chmod +x start.sh
	@chmod +x script/*.sh 2>/dev/null || true
	@mkdir -p history hosts paths payloads headers responses
	@echo "Creating default configuration..."
	@if [ ! -f _request_config.json ]; then \
		echo '{"host":"http://localhost:3000","path":"/","payload":{},"headers":[]}' > _request_config.json; \
	fi
	@echo "Curly environment bootstrap complete!"
	@echo ""
	@echo "To start using Curly:"
	@echo "  source ./start.sh"
	@echo ""

# Clean up temporary files and audit directories
clean:
	@echo "Cleaning up Curly environment..."
	@rm -f _response.json
	@rm -f /tmp/curly_* 2>/dev/null || true
	@rm -rf dbt_jobs_audit fivetran_connectors_audit zoom_engagements_audit
	@echo "Cleanup complete!"

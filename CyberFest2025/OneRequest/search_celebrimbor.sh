#!/bin/bash

# Script to search for Celebrimbor's UUID (ccb14650) across paginated API responses
# Base URL and headers
BASE_URL="https://one-request.malteksolutions.com/v2/locations/7e63c222-fa15-4e47-ae2f-e77d27a1a8ce/activities"
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlfdmVyc2lvbiI6InYyIiwidXNlcl9pZCI6IjE5NGVmOTE1LWNmNmItNGQ3NC1iYjViLWYzNjgxMmI0ZDg5YyIsIm5hbWUiOiJBIG5hbWVtZW4iLCJlbWFpbCI6Im5hbWVtZW5AZXhhbXBsZS5jb20iLCJyb2xlIjoidXNlciIsImV4cGlyZXMiOjE3NTI2NTEzNTkuMTEwNjY2M30.Og2PGmcjYOCVuuPYS8fgVVEwbyD69iOV5P7O_4nhfRM"
#SEARCH_STRING="ccb14650"
SEARCH_STRING="737530c6-7980-42d7-8c8f-9ace9949dfba" 
PAGE_SIZE=100

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Starting search for UUID: $SEARCH_STRING"
echo "API Endpoint: $BASE_URL"
echo "Page Size: $PAGE_SIZE"
echo "----------------------------------------"

# Initialize variables
page=1
found=false
total_pages_checked=0

# Function to make API call and search for the string
search_page() {
    local page_num=$1
    echo -e "${YELLOW}Searching page: $page_num${NC}"

    local url="${BASE_URL}?page=${page_num}&size=${PAGE_SIZE}"
    
    echo -e "${YELLOW}Checking page $page_num...${NC}"
    
    # Make the API call
    response=$(curl -s -X 'GET' \
        "$url" \
        -H 'accept: application/json' \
        -H "Authorization: Bearer $TOKEN")
    
    # Check if curl was successful
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to fetch page $page_num${NC}"
        return 1
    fi
    
    # Check if response contains error
    if echo "$response" | grep -q '"detail"'; then
        echo -e "${RED}API Error on page $page_num: $(echo "$response" | grep -o '"detail":"[^"]*"')${NC}"
        return 1
    fi
    
    # Debug: Show first 500 characters of response
    #echo -e "${YELLOW}Debug: First 500 chars of response:${NC}"
    #echo "$response" | head -c 500
    #echo ""
    #echo "----------------------------------------"
    
    # Search for the target string
    if echo "$response" | grep -q "$SEARCH_STRING"; then
        echo -e "${GREEN}FOUND! String '$SEARCH_STRING' found on page $page_num${NC}"
        echo "Full response for page $page_num:"
        echo "$response" | jq . 2>/dev/null || echo "$response"
        echo "----------------------------------------"
        found=true
        return 0
    else
        #echo "Not found on page $page_num"
        # Debug: Show if any similar strings exist
        #echo -e "${YELLOW}Debug: Checking for partial matches...${NC}"
        #echo "$response" | grep -o "cdd[^\"]*" | head -5
        #echo "----------------------------------------"
        echo ""
    fi
    
    # Check if this is the last page (no more items)
    items_count=$(echo "$response" | jq '.items | length' 2>/dev/null)
    if [ "$items_count" = "0" ] || [ "$items_count" = "null" ]; then
        echo -e "${YELLOW}No more items found. Reached end of pages.${NC}"
        return 2
    fi
    
    return 0
}

# Main loop to iterate through pages
while [ $found = false ]; do
    echo -e "${YELLOW}Processing page $page...${NC}"
    search_page $page
    exit_code=$?

    total_pages_checked=$((total_pages_checked + 1))

    # Check exit code
    if [ $exit_code -eq 0 ]; then
        # Continue to next page if not found
        if [ $found = false ]; then
            page=$((page + 1))
        fi
    elif [ $exit_code -eq 2 ]; then
        # End of pages reached
        echo -e "${YELLOW}Reached end of available pages.${NC}"
        break
    else
        # Error occurred
        echo -e "${RED}Error occurred while processing page $page${NC}"
        break
    fi

    # Safety check to prevent infinite loop
    if [ $total_pages_checked -gt 1000 ]; then
        echo -e "${RED}Safety limit reached (1000 pages checked). Stopping.${NC}"
        break
    fi
done

# Summary
echo "========================================="
echo "Search completed!"
echo "Pages checked: $total_pages_checked"
if [ $found = true ]; then
    echo -e "${GREEN}Result: String '$SEARCH_STRING' was FOUND!${NC}"
else
    echo -e "${RED}Result: String '$SEARCH_STRING' was NOT FOUND${NC}"
fi
echo "========================================="

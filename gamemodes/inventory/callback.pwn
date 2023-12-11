hook OnQueryFinished(extraid, thread)
{
    static rows, fields;
    switch(thread)
    {
        case THREAD_LOAD_INVENTORY:
        {
            static
                name[32];

            cache_get_data(rows, fields);

            for (new i = 0; i < rows && i < MAX_INVENTORY; i ++) {
                InventoryData[extraid][i][invExists] = true;
                InventoryData[extraid][i][invID] = cache_get_field_int(i, "invID");
                InventoryData[extraid][i][invModel] = cache_get_field_int(i, "invModel");
                InventoryData[extraid][i][invQuantity] = cache_get_field_int(i, "invQuantity");
                cache_get_field_content(i, "invItem", name, sizeof(name));
                strpack(InventoryData[extraid][i][invItem], name, 32 char);
            }
            printf("[MySQL] Loaded inventory player ( OnQueryFinished(%s, THREAD_LOAD_INVENTORY) )", ReturnName(extraid));
        }
    }
    return 1;
}
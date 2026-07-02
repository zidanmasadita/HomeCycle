import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const supabaseUrl = Deno.env.get('SUPABASE_URL') as string
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') as string

serve(async (req) => {
  try {
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Find food items expiring in <= 2 days
    const today = new Date();
    const inTwoDays = new Date();
    inTwoDays.setDate(today.getDate() + 2);

    const { data: foodItems, error: itemsError } = await supabase
      .from('food_items')
      .select('id, user_id, custom_name, estimated_expired_date')
      .eq('actual_status', 'active')
      .lte('estimated_expired_date', inTwoDays.toISOString().split('T')[0])
      .gte('estimated_expired_date', today.toISOString().split('T')[0]);

    if (itemsError) throw itemsError;

    if (foodItems && foodItems.length > 0) {
      const notifications = foodItems.map(item => ({
        user_id: item.user_id,
        food_item_id: item.id,
        type: 'expiring_soon',
        title: 'Item Expiring Soon',
        body: `Your ${item.custom_name || 'item'} is expiring on ${item.estimated_expired_date}. Don't let it go to waste!`,
        scheduled_at: new Date().toISOString(),
      }));

      const { error: insertError } = await supabase
        .from('notifications')
        .insert(notifications);

      if (insertError) throw insertError;
    }

    return new Response(JSON.stringify({ success: true, notifications_created: foodItems?.length || 0 }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 400,
    })
  }
})

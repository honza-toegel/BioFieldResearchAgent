<template>
  <div>
    <h2>Real-Time Data</h2>
    <p><strong>Current Time:</strong> {{ currentTime }}</p>
    <p><strong>App Uptime:</strong> {{ uptime }}</p>
    <p><strong>User Name:</strong> {{ userName }}</p>

    <input v-model="newUserName" placeholder="Change User Name" />
    <button @click="updateUserName">Update Name</button>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref, onMounted, onBeforeUnmount } from 'vue';

export default defineComponent({
  name: 'RealTimeData',
  setup() {
    const currentTime = ref<string>('');
    const uptime = ref<string>('');
    const userName = ref<string>('');
    const newUserName = ref<string>('');
    let ws: WebSocket;

    const connectWebSocket = () => {
      ws = new WebSocket('ws://localhost:8000/ws/realtime');
      ws.onmessage = (event) => {
        const data = JSON.parse(event.data);
        currentTime.value = data.current_time;
        uptime.value = data.uptime;
        userName.value = data.user_name;
      };
    };

    const updateUserName = async () => {
      const response = await fetch('http://localhost:8000/update_user_name', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ new_name: newUserName.value }),
      });
      console.log("changing user name to: " + newUserName.value);
      const result = await response.json();
      console.log(result.message);
    };

    onMounted(() => {
      connectWebSocket();
    });

    onBeforeUnmount(() => {
      if (ws) {
        ws.close();
      }
    });

    return {
      currentTime,
      uptime,
      userName,
      newUserName,
      updateUserName,
    };
  },
});
</script>

<style scoped>
/* Add your styles here */
</style>

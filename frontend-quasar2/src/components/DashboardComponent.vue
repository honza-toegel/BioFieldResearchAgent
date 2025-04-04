<template>
  <q-page class="flex flex-center">
    <div class="q-pa-md" style="width: 100%; max-width: 800px;">
      <q-card flat>
        <q-card-section>
          <h2 class="text-center">Live Stock Exchange Data</h2>
        </q-card-section>
        <q-card-section>
          <vue-e-charts :option="chartOptions" ref="chartRef" style="height: 400px;" />
        </q-card-section>
      </q-card>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { reactive, ref, watch, onBeforeUnmount } from 'vue';
import { useWebSocket } from '@vueuse/core';
import { use } from 'echarts/core';
import VueECharts from 'vue-echarts';
import { CanvasRenderer } from 'echarts/renderers';
import { LineChart } from 'echarts/charts';
import { GridComponent, TooltipComponent } from 'echarts/components';

// Register ECharts modules
use([CanvasRenderer, LineChart, GridComponent, TooltipComponent]);

function extractTimeFromISO(isoTimestamp: string): string {
    try {
        const date = new Date(isoTimestamp);
        const hours = date.getHours().toString().padStart(2, '0');
        const minutes = date.getMinutes().toString().padStart(2, '0');
        const seconds = date.getSeconds().toString().padStart(2, '0');
        return `${hours}:${minutes}:${seconds}`;
    } catch (error) {
        console.error("Invalid ISO timestamp", error);
        return "Invalid time";
    }
}

type ExchangeRate = {
  assetName: string;        // Represents the name of the asset (e.g., "BTC")
  exchangeRate: number;     // Represents the exchange rate, a random float between 0.5 and 1.2
  timestamp: string;        // ISO 8601 formatted timestamp (e.g., "2025-01-25T14:34:00.123Z")
};

type ChartOptions = {
  title: {
    text: string;
    left: string;
  };
  tooltip: {
    trigger: string;
  };
  xAxis: {
    type: string;
    boundaryGap: boolean;
    data: string[];
  };
  yAxis: {
    type: string;
    scale: boolean;
    axisLabel: {
      formatter: string;
    };
  };
  series: {
    name: string;
    type: string;
    smooth: boolean;
    data: number[];
  }[];
};

// Reactive chart options
const chartOptions = reactive<ChartOptions>({
  title: {
    text: 'Live Stock Exchange Data',
    left: 'center',
  },
  tooltip: {
    trigger: 'axis',
  },
  xAxis: {
    type: 'category',
    boundaryGap: false,
    data: [],
  },
  yAxis: {
    type: 'value',
    scale: true,
    axisLabel: {
      formatter: '{value}',
    },
  },
  series: [
    {
      name: 'Exchange Rate',
      type: 'line',
      smooth: true,
      data: [],
    },
  ],
});

const chartRef = ref(); // Reference for ECharts component

const { status, ws, close } = useWebSocket('ws://localhost:8000/ws/exchangerates', {
  autoReconnect: true,
});

const updateChart = (exchangeRate: ExchangeRate) => {
  console.log('Update chart data: ' + JSON.stringify(exchangeRate));
  const timestamp = extractTimeFromISO(exchangeRate.timestamp);
  if (!chartOptions.xAxis.data.includes(timestamp)) {
    chartOptions.xAxis.data.push(timestamp);
    if (chartOptions.series[0]) {
      chartOptions.series[0].data.push(exchangeRate.exchangeRate);

      // Limit to the latest 50 points
      if (chartOptions.xAxis.data.length > 50) {
        chartOptions.xAxis.data.shift();
        chartOptions.series[0].data.shift();
      }
    } 
  }
};

// Watch WebSocket status and set up the message listener when connected
watch(status, (newStatus) => {
  if (newStatus === 'OPEN') {
    console.log('WebSocket connected!');
    ws.value?.addEventListener('message', (event: MessageEvent) => {
      try {
        const message: ExchangeRate = JSON.parse(event.data);
        updateChart(message);
      } catch (err) {
        console.error('Failed to process WebSocket message:', err);
      }
    });
  }
});

onBeforeUnmount(() => {
  close();
});
</script>

<style>
.q-page {
  background: #f5f5f5;
}
</style>

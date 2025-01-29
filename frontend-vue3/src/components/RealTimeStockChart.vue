<template>
  <div>
    <h1>Real-Time Stock Exchange Rates</h1>

    <div>
      <h2>Simple Graph</h2>
      <canvas id="simpleGraph"></canvas>
    </div>

  <!--div>
      <h2>Candlestick Chart</h2>
      <label for="timeFrame">Time Frame:</label>
      <select id="timeFrame" v-model="timeFrame">
        <option value="1m">1 Minute</option>
        <option value="5m">5 Minutes</option>
        <option value="15m">15 Minutes</option>
        <option value="1h">1 Hour</option>
      </select>
      <canvas id="candlestickChart"></canvas>
    </div-->
  </div>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, toRaw } from "vue";
import { Chart, registerables } from "chart.js";
import { CandlestickController, CandlestickElement } from "chartjs-chart-financial";
import "chartjs-adapter-date-fns";

Chart.register(...registerables, CandlestickController, CandlestickElement);

export default defineComponent({
  name: "StockExchangeRates",
  setup() {
    const simpleGraph = ref<Chart | null>(null);
    const candlestickChart = ref<Chart | null>(null);
    const timeFrame = ref("1m");

    const simpleGraphData = ref<number[]>([]);
    const simpleGraphLabels = ref<string[]>([]);

    const candlestickData = ref<any[]>([]); // Each element: { t, o, h, l, c }

    const ws = new WebSocket("ws://localhost:8000/ws/realtime/exchange");

    onMounted(() => {
      setupSimpleGraph();
      setupCandlestickChart();

      ws.onmessage = (event) => {
        const data = JSON.parse(event.data);
        console.log('Received stock exchange data from backend, updating graphs: ' + event.data);

        updateSimpleGraphData(data);
        updateCandlestickGraphData(data);
      };
    });

    const setupSimpleGraph = () => {
      const ctx = (document.getElementById("simpleGraph") as HTMLCanvasElement).getContext("2d");
      if (ctx) {
        simpleGraph.value = new Chart(ctx, {
          type: "line",
          data: {
            labels: simpleGraphLabels.value,
            datasets: [
              {
                label: "Stock Rate",
                //data: [1.3, 1.2, 1.1, 1.2, 1.2],
                data: simpleGraphData.value,
                borderColor: "blue",
                borderWidth: 2,
                tension: 0.1,
              },
            ],
          },
          options: {
            responsive: true,
            plugins: {
              annotation: {
                annotations: {
                  lastValueLine: {
                    type: "line",
                    borderColor: "red",
                    borderWidth: 1,
                    scaleID: "y",
                    value: 0,
                  },
                },
              },
            },
          },
        });
      }
    };

    const setupCandlestickChart = () => {
      const ctx = (document.getElementById("candlestickChart") as HTMLCanvasElement).getContext("2d");
      if (ctx) {
        candlestickChart.value = new Chart(ctx, {
          type: "candlestick",
          data: {
            datasets: [
              {
                label: "Candlestick",
                data: candlestickData.value,
                borderColor: "#000000",
              },
            ],
          },
          options: {
            responsive: true,
            scales: {
              x: { type: "time" },
              y: {},
            },
            plugins: {
              annotation: {
                annotations: {
                  lastValueLine: {
                    type: "line",
                    borderColor: "red",
                    borderWidth: 1,
                    scaleID: "y",
                    value: 0,
                  },
                },
              },
            },
          },
        });
      }
    };

    const updateSimpleGraphData = (data: { rate: number; timestamp: string }) => {
      const { rate, timestamp } = data;

      // Update simple graph data
      const updatedSimpleData = [...simpleGraphData.value];
      const updatedSimpleLabels = [...simpleGraphLabels.value];
      updatedSimpleData.push(rate);
      updatedSimpleLabels.push(timestamp);

      if (updatedSimpleData.length > 100) {
        updatedSimpleData.shift();
        updatedSimpleLabels.shift();
      }

      simpleGraphData.value = updatedSimpleData;
      simpleGraphLabels.value = updatedSimpleLabels;

      if (simpleGraph.value) {
        simpleGraph.value.data.datasets[0].data = updatedSimpleData;
        simpleGraph.value.data.labels = updatedSimpleLabels;
        simpleGraph.value.update();
      }
    }

    const updateCandlestickGraphData = (data: { rate: number; timestamp: string }) => {
      const { rate, timestamp } = data;

      // Update candlestick chart data
      const updatedCandlestickData = [...candlestickData.value];
      const lastCandle = updatedCandlestickData[updatedCandlestickData.length - 1];
      const timeDiff = calculateTimeDiff(timestamp, lastCandle?.t, timeFrame.value);

      if (timeDiff) {
        updatedCandlestickData.push({
          t: timestamp,
          o: rate,
          h: rate,
          l: rate,
          c: rate,
        });
      } else if (lastCandle) {
        lastCandle.h = Math.max(lastCandle.h, rate);
        lastCandle.l = Math.min(lastCandle.l, rate);
        lastCandle.c = rate;
      }

      candlestickData.value = updatedCandlestickData;

      if (candlestickChart.value) {
        candlestickChart.value.data.datasets[0].data = updatedCandlestickData;
        candlestickChart.value.update();
      }
    };

    const calculateTimeDiff = (current: string, last: string, frame: string) => {
      const currentTime = new Date(current).getTime();
      const lastTime = new Date(last).getTime();
      const frameMs = frame === "1m" ? 60000 : frame === "5m" ? 300000 : frame === "15m" ? 900000 : 3600000;

      return currentTime - lastTime > frameMs;
    };

    return { timeFrame };
  },
});
</script>

<style scoped>
canvas {
  width: 100%;
  height: 400px;
}
</style>

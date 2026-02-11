# 基础镜像：官方 Ollama
FROM ollama/ollama:latest

RUN apt-get update && apt-get install -y --no-install-recommends curl \
  && rm -rf /var/lib/apt/lists/*
# （可选）预先声明模型目录，便于后续维护
ENV OLLAMA_MODELS=/root/.ollama

# 先把 serve 跑起来（后台），再拉模型；最后干净地结束 serve
# 注意：sleep 时间按网络情况调大，或改用健康检查循环
RUN bash -lc "\
  ollama serve & \
  for i in {1..60}; do sleep 1; if curl -sf http://127.0.0.1:11434/api/version >/dev/null; then break; fi; done; \
  ollama pull deepseek-r1:8b-llama-distill-q4_K_M; \
  pkill -9 ollama || true \
"

# 暴露 API 端口
EXPOSE 11434

# 默认启动服务
CMD ["ollama","serve"]

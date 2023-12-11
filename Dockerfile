FROM golang:alpine AS build

ARG TARGETARCH

RUN apk --no-cache add ca-certificates git

RUN git clone https://codeberg.org/video-prize-ranch/rimgo.git /rimgo

WORKDIR /rimgo

RUN go mod download
RUN GOOS=linux GOARCH=$TARGETARCH CGO_ENABLED=0 go build -ldflags "-X codeberg.org/video-prize-ranch/rimgo/pages.VersionInfo=$(date '+%Y-%m-%d')-$(git rev-list --abbrev-commit -1 HEAD)"

FROM scratch as bin

ENV PRIVACY_COUNTRY="United States"
ENV PRIVACY_PROVIDER=Homelab
ENV PRIVACY_CLOUDFLARE=true
ENV PRIVACY_NOT_COLLECTED=false
ENV PRIVACY_IP=true
ENV PRIVACY_URL=true
ENV PRIVACY_DEVICE=true
ENV PRIVACY_DIAGNOSTICS=false

WORKDIR /app

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /rimgo .

EXPOSE 3000

CMD ["/app/rimgo"]
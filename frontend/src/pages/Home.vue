<template>
	<div class="max-w-3xl py-12 mx-auto">
		<Button
			icon-left="code"
			@click="$resources.ping.fetch"
			:loading="$resources.ping.loading"
		>
			Нажмите, чтобы отправить запрос 'ping'
		</Button>
		<div>
			{{ $resources.ping.data }}
		</div>
		<pre>{{ $resources.ping }}</pre>

		<Button @click="showDialog = true">Открыть Диалог</Button>
		<Dialog title="Заголовок" v-model="showDialog"> Содержимое диалога </Dialog>
	</div>
</template>

<script>
import { Dialog } from 'frappe-ui'

export default {
	name: 'Home',
	data() {
		return {
			showDialog: false,
		}
	},
	resources: {
		ping: {
			url: 'ping',
		},
	},
	components: {
		Dialog,
	},
}
</script>

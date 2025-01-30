import { Box, Link, Stack } from '@mui/material';

export default function Footer() {
  return (
    <Box padding={4} borderTop={1} borderColor="grey.700">
      <Stack direction="row" gap={4}>
        <Stack gap={1}>
          <Link href="/">Home</Link>
        </Stack>
      </Stack>
    </Box>
  );
}
